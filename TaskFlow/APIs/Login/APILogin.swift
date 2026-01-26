//
//  APILogin.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Modèles représentant la requête et la réponse
//  de l’API d’authentification.
//

import Foundation

// Requête de login
// (email + mot de passe)
struct LoginRequest: Codable {
    // Email de l’utilisateur
    let email: String
    // Mot de passe de l’utilisateur
    let password: String
}

// Réponse de login
/// - un access token JWT
/// - un refresh token longue durée
struct LoginResponse: Codable {

    // Access token JWT (utilisé pour les appels API)
    let token: String

    // Refresh token (utilisé pour reconstruire la session)
    let refreshToken: String

    // Mapping entre les clés JSON de l’API
    // et les propriétés Swift
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
    }
}
