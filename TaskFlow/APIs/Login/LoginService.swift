//
//  LoginService.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation

// Service de Login
final class LoginService {

    static let shared = LoginService()
    private init() {}
    
    func login(email: String, password: String) async throws -> LoginResponse {
        // URL
        let url = AppConfig.baseURL.appendingPathComponent("/api/login_check")

        // Création du corps de la requete
        let body = LoginRequest(email: email, password: password)

        // Appel de l'API
        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body
        )
    }
}

