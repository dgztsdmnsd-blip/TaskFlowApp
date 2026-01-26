//
//  RefreshService.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Service responsable du renouvellement de l’access token JWT
//  à partir du refresh token.
//  Il est utilisé après une authentification biométrique
//  ou lorsqu’une session doit être reconstruite.
//

import Foundation

final class RefreshService {

    // Singleton : un seul service de refresh partagé
    static let shared = RefreshService()
    private init() {}

    /// Renouvelle l’access token JWT à partir d’un refresh token valide.
    func refreshToken(using refreshToken: String) async throws -> String {

        // URL de l’endpoint de refresh
        let url = AppConfig.baseURL.appendingPathComponent("/api/token/refresh")

        // Log
        print("REFRESH url:", url)

        // Corps de la requête attendu par l’API
        struct Body: Encodable {
            let refresh_token: String
        }

        // Structure de réponse attendue
        struct Response: Decodable {
            let token: String
        }

        // Appel réseau générique
        // - requiresAuth: false → pas de Bearer token nécessaire
        // - retry: false → pas de refresh récursif
        let response: Response = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(refresh_token: refreshToken),
            requiresAuth: false,
            retry: false
        )

        // Sauvegarde du nouvel access token en mémoire
        SessionManager.shared.saveAccessToken(response.token)

        return response.token
    }
}
