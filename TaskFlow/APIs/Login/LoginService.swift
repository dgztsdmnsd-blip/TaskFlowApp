//
//  LoginService.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Service réseau responsable de l’authentification
//  via email et mot de passe.
//

import Foundation

final class LoginService {

    // Singleton : un seul service de login partagé
    static let shared = LoginService()
    private init() {}

    /// Authentifie un utilisateur via l’API.
    ///
    /// Cette méthode :
    /// - appelle l’endpoint  /api/login_check
    /// - envoie les identifiants utilisateur
    /// - récupère les tokens d’authentification
    func login(email: String, password: String) async throws -> LoginResponse {

        // Construction de l’URL de l’endpoint de login
        let url = AppConfig.baseURL.appendingPathComponent("/api/login_check")

        // Log
        print("url: \(url)")

        // Corps de la requête attendu par l’API
        struct Body: Encodable {
            let email: String
            let password: String
        }

        // Appel réseau générique
        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(email: email, password: password),
            requiresAuth: false
        )
    }
}
