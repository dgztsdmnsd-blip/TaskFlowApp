//
//  APILogin.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation

// Structure pour la requete de Login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Structure de réponse de Login
struct LoginResponse: Codable {
    let token: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
    }
}


