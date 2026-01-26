//
//  APIClient.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Client réseau générique de l’application.
//  Il centralise :
//  - la construction des requêtes HTTP
//  - l’injection du token JWT
//  - la gestion des erreurs HTTP
//  - le décodage des réponses JSON
//

import Foundation

/// Erreurs API
enum APIError: Error {

    // URL invalide
    case invalidURL

    // Réponse non HTTP
    case invalidResponse

    // Accès non autorisé (token manquant, expiré ou invalide)
    case unauthorized(message: String?)

    // Erreur HTTP générique (4xx / 5xx)
    case httpError(Int, message: String?)

    // Erreur lors du décodage JSON
    case decodingError(Error)
}

/// Réponse d’erreur backend
struct APIErrorResponse: Decodable {
    let message: String?
}

/// APIClient
final class APIClient {

    // Un seul client réseau partagé
    static let shared = APIClient()
    private init() {}

    // Requête générique
    // Exécute une requête HTTP générique et retourne un objet décodé.
    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Encodable? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = true,
        retry: Bool = true
    ) async throws -> T {

        // Construction de la requête
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method

        // Headers
        var allHeaders = headers

        if requiresAuth,
           headers["Authorization"] == nil,
           let token = SessionManager.shared.getAccessToken() {
            allHeaders["Authorization"] = "Bearer \(token)"
        }

        // Application des headers à la requête
        allHeaders.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        // Body
        if let body {
            // Encodage JSON générique
            urlRequest.httpBody = try JSONEncoder()
                .encode(AnyEncodable(body))

            urlRequest.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        // Appel réseau
        let (data, response) = try await
            URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Tentative de décodage d’un message d’erreur backend
        let apiMessage = try? JSONDecoder()
            .decode(APIErrorResponse.self, from: data)
            .message

        // Gestion des statuts HTTP
        switch http.statusCode {

        case 200..<300:
            // Succès → on continue
            break

        case 401 where retry && requiresAuth:
            // Token invalide ou expiré
            throw APIError.unauthorized(message: apiMessage)

        case 401:
            // Échec définitif → on nettoie la session en mémoire
            SessionManager.shared.clear()
            throw APIError.unauthorized(message: apiMessage)

        default:
            // Autres erreurs HTTP
            throw APIError.httpError(
                http.statusCode,
                message: apiMessage
            )
        }

        // Décodage de la réponse
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// AnyEncodable
/// Wrapper permettant d’encoder dynamiquement
/// un type Encodable sans connaître son type concret.
struct AnyEncodable: Encodable {

    private let encodeFunc: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
