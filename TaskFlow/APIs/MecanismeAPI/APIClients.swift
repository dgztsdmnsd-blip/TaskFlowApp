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
    func request<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Encodable? = nil,
        headers: [String: String] = [:],
        retry: Bool = true
    ) async throws -> T {

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method

        var allHeaders = headers

        if headers["Authorization"] == nil,
           let token = SessionManager.shared.getAccessToken() {
            allHeaders["Authorization"] = "Bearer \(token)"
        }

        allHeaders.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let body {
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            break

        case 401 where retry && !url.path.contains("/api/token/refresh"):
            _ = try await RefreshService.shared.refreshToken()
            return try await self.request(
                url: url,
                method: method,
                body: body,
                headers: headers,
                retry: false
            )

        case 401:
            SessionManager.shared.clear()
            throw APIError.unauthorized

        default:
            throw APIError.httpError(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

}

// AnyEncodable
// Wrapper permettant de passer un Encodable "inconnu" à JSONEncoder.
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
