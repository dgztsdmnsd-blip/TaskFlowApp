//
//  AuthService.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation

final class AuthService {

    static let shared = AuthService()
    private init() {}

    // Request reset code
    func requestResetCode(email: String) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/request-reset-code")

        struct Body: Encodable {
            let email: String
        }

        print("RequestResetCode →", url)

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email),
            requiresAuth: false
        )
    }

    // Verify reset code
    func verifyResetCode(email: String, code: String) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/verify-reset-code")

        struct Body: Encodable {
            let email: String
            let code: String
        }

        print("🔎 VerifyResetCode →", url)

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code),
            requiresAuth: false
        )
    }

    // Update password
    func updatePasswordWithCode(
        email: String,
        code: String,
        newPassword: String
    ) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/reset-password")

        struct Body: Encodable {
            let email: String
            let code: String
            let password: String
        }

        print("ResetPassword →", url)

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code, password: newPassword),
            requiresAuth: false
        )
    }
    
    func updatePasswordWithToken(
        token: String,
        password: String
    ) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/reset-password")

        struct Body: Encodable {
            let token: String
            let password: String
        }

        print("Reset password with token → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(token: token, password: password),
            requiresAuth: false
        )
    }
    
    
    func validateResetCode(
        email: String,
        code: String
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/reset/validate")

        struct Body: Encodable {
            let email: String
            let code: String
        }

        print("Validate reset code → URL:", url)

        let _: EmptyResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code),
            requiresAuth: false
        )

    }
}
