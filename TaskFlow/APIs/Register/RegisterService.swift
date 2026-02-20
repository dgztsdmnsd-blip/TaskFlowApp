//
//  RegisterService.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  Service réseau responsable de :
//  - L’inscription d’un utilisateur
//  - La mise à jour du profil
//  - La mise à jour du mot de passe
//  - La demande de reset code
//

import Foundation

// Service de gestion de l’inscription et du compte utilisateur
final class RegisterService {

    // Instance partagée (Singleton)
    static let shared = RegisterService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Inscription d’un nouvel utilisateur
    func register(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> RegisterResponse {
        
        // URL API
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/register")
        
        // Logs debug
        if AppConfig.version == .dev {
            print("Register → URL:", url)
            print("Payload:", [
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ])
        }
        
        // Body envoyé au backend
        struct Body: Encodable {
            let firstName: String
            let lastName: String
            let email: String
            let password: String
        }
        
        do {
            // Requête POST non authentifiée
            let response: RegisterResponse = try await APIClient.shared.request(
                url: url,
                method: "POST",
                body: Body(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                ),
                requiresAuth: false
            )
            
            if AppConfig.version == .dev {
                print("Register succès:", response)
            }
            return response
            
        } catch {
            if AppConfig.version == .dev {
                print("Register erreur:", error)
            }
            throw error
        }
    }
    
    // Mise à jour des informations d’identité
    func updateIdentity(
        id: Int,
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> RegisterResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/update/\(id)")

        struct Body: Encodable {
            let firstName: String
            let lastName: String
            let email: String
        }

        if AppConfig.version == .dev {
            print("Update identity → URL:", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(
                firstName: firstName,
                lastName: lastName,
                email: email
            ),
            requiresAuth: true
        )
    }

    // Mise à jour du mot de passe utilisateur
    func updatePassword(
        id: Int,
        password: String
    ) async throws -> RegisterResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/update/\(id)")

        struct Body: Encodable {
            let password: String
        }

        if AppConfig.version == .dev {
            print("Update password → URL:", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(password: password),
            requiresAuth: true
        )
    }
    
    // Demande d’envoi d’un code de reset
    func requestResetCode(email: String) async throws -> APIMessageResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/auth/request-reset-code")

        struct Body: Encodable {
            let email: String
        }

        if AppConfig.version == .dev {
            print("Request reset code → URL:", url)
            print("Email:", email)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email),
            requiresAuth: false
        )
    }
}
