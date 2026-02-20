//
//  AuthService.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  Service gérant les opérations d’authentification liées
//  à la réinitialisation du mot de passe :
//  - Demande de code
//  - Vérification du code
//  - Mise à jour du mot de passe
//

import Foundation

// Service d’authentification
final class AuthService {

    // Instance partagée (Singleton)
    static let shared = AuthService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Demande d’envoi d’un code de réinitialisation
    func requestResetCode(email: String) async throws -> APIMessageResponse {

        // URL API
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/request-reset-code")

        // Body envoyé au backend
        struct Body: Encodable {
            let email: String
        }

        if AppConfig.version == .dev {
            print("RequestResetCode →", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email),
            requiresAuth: false
        )
    }

    // Vérifie le code de réinitialisation
    func verifyResetCode(email: String, code: String) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/verify-reset-code")

        struct Body: Encodable {
            let email: String
            let code: String
        }

        if AppConfig.version == .dev {
            print("VerifyResetCode →", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code),
            requiresAuth: false
        )
    }

    // Met à jour le mot de passe via email + code
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

        if AppConfig.version == .dev {
            print("ResetPassword (code) →", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code, password: newPassword),
            requiresAuth: false
        )
    }
    
    // Met à jour le mot de passe via token
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
        if AppConfig.version == .dev {
            print("ResetPassword (token) →", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(token: token, password: password),
            requiresAuth: false
        )
    }
    
    // Valide un code sans changer le mot de passe
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

        if AppConfig.version == .dev {
            print("ValidateResetCode →", url)
        }

        let _: EmptyResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, code: code),
            requiresAuth: false
        )
    }
}
