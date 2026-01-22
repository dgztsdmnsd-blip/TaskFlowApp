//
//  APIClients.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation

// APIError
// Enum centralisant toutes les erreurs possibles liées aux appels API.
// Permet d'avoir une gestion d'erreurs cohérente dans toute l'app.
enum APIError: Error {
    /// L'URL construite est invalide
    case invalidURL

    /// La réponse n'est pas une HTTPURLResponse
    case invalidResponse

    /// Erreur d'authentification (401)
    case unauthorized

    /// Erreur HTTP générique (status code ≠ 2xx)
    case httpError(Int)

    /// Erreur lors du décodage du JSON
    case decodingError(Error)
}

// APIClient
// Client HTTP générique responsable de :
 // - construire les requêtes
 // - gérer les headers
 // - exécuter les appels réseau
 // - logger les échanges
 // - gérer les erreurs HTTP
 // - décoder les réponses JSON
final class APIClient {

    /// Singleton partagé dans toute l'application
    static let shared = APIClient()

    /// Initialiseur privé pour empêcher plusieurs instances
    private init() {}

    /// Méthode générique permettant d'appeler n'importe quelle API
    /// - Parameters:
    ///   - url: URL complète de l'endpoint
    ///   - method: Méthode HTTP (GET par défaut)
    ///   - body: Corps de la requête (Encodable)
    ///   - headers: Headers HTTP personnalisés
    /// - Returns: Un objet décodé du type attendu
    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {

        // 1 - Construction de la requête
        var request = URLRequest(url: url)
        request.httpMethod = method

        // Ajout des headers personnalisés
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        // 2 - Ajout du body si présent (POST / PUT / PATCH)
        if let body {
            // Encodage générique du body grâce à AnyEncodable
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // 3 - LOG : corps de la requête (debug uniquement)
        if let body = request.httpBody,
           let json = String(data: body, encoding: .utf8) {
            print("Request body:", json)
        }

        // 4 - Appel réseau asynchrone
        let (data, response) = try await URLSession.shared.data(for: request)

        // 5 - Validation de la réponse HTTP
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // LOG status code
        print("Status code:", http.statusCode)

        // LOG réponse brute
        if let raw = String(data: data, encoding: .utf8) {
            print("Raw response:", raw)
        }

        // 6 - Gestion des codes HTTP
        switch http.statusCode {
        case 200..<300:
            // Succès → on continue
            break
        case 401:
            // Non autorisé → problème d'authentification
            throw APIError.unauthorized
        default:
            // Autres erreurs HTTP
            throw APIError.httpError(http.statusCode)
        }

        // 7 - Décodage de la réponse JSON
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Erreur de décodage → on encapsule pour plus de clarté
            throw APIError.decodingError(error)
        }
    }
}

// AnyEncodable
// Wrapper permettant de passer un Encodable "inconnu" à JSONEncoder.
// Swift n'autorise pas directement `Encodable` comme type concret.
struct AnyEncodable: Encodable {

    /// Fonction d'encodage stockée dynamiquement
    private let encodeFunc: (Encoder) throws -> Void

    /// Initialise le wrapper avec n'importe quel type Encodable
    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }

    /// Appelé par JSONEncoder pour encoder le body
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
