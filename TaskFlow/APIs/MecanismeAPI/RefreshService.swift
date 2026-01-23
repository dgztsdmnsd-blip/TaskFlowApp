//
//  RefreshService.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

import Foundation

final class RefreshService {

    static let shared = RefreshService()
    private init() {}

    func refreshToken() async throws -> String {
        guard let refresh = SessionManager.shared.getRefreshToken() else {
            throw APIError.unauthorized
        }

        let url = AppConfig.baseURL.appendingPathComponent("/api/token/refresh")

        struct RefreshBody: Encodable {
            let refresh_token: String
        }

        struct RefreshResponse: Decodable {
            let token: String
        }

        let response: RefreshResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: RefreshBody(refresh_token: refresh),
            retry: false
        )

        SessionManager.shared.saveTokens(
            access: response.token,
            refresh: refresh
        )

        return response.token
    }
}
