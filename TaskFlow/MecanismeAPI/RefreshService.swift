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

        let url = AppConfig.baseURL.appendingPathComponent("/api/token/refresh")

        struct Body: Encodable {
            let refresh_token: String
        }

        let response: RefreshResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(refresh_token: refreshToken),
            requiresAuth: false,
            retry: false
        )

        // 🔐 Sauvegarde du NOUVEAU refresh token
        try SessionManager.shared.updateRefreshToken(response.refreshToken)

        // 🔑 Sauvegarde du nouvel access token
        SessionManager.shared.saveAccessToken(response.token)

        return response.token
    }

    
    struct RefreshResponse: Decodable {
        let token: String
        let refreshToken: String

        enum CodingKeys: String, CodingKey {
            case token
            case refreshToken = "refresh_token"
        }
    }

}
