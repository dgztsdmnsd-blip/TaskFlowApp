//
//  RegisterService.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  Service réseau responsable de l'inscription d'un nouvel utilisateur
//

import Foundation

final class RegisterService {

    static let shared = RegisterService()
    private init() {}

    func register(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> RegisterResponse {
        
        let url = AppConfig.baseURL.appendingPathComponent("/api/users/register")
        
        print("Register → URL:", url)
        print("Payload:", [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ])
        
        struct Body: Encodable {
            let firstName: String
            let lastName: String
            let email: String
            let password: String
        }
        
        do {
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
            
            print("Register succès:", response)
            return response
            
        } catch {
            print("Register erreur:", error)
            throw error
        }
    }
    
    func updateIdentity(
        id: Int,
        firstName: String,
        lastName: String,
        email: String
    ) async throws -> RegisterResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/users/update/\(id)")

        struct Body: Encodable {
            let firstName: String
            let lastName: String
            let email: String
        }

        print("Update identity → URL:", url)

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

    func updatePassword(
        id: Int,
        password: String
    ) async throws -> RegisterResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/users/update/\(id)")

        struct Body: Encodable {
            let password: String
        }

        print("Update password → URL:", url)

         return try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(password: password),
            requiresAuth: true
        )
    }   
}

