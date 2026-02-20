//
//  ProfileService.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Service réseau responsable de la récupération
//  du profil de l’utilisateur connecté.
//

import Foundation

// Service de gestion du profil utilisateur
final class ProfileService {

    // Instance partagée (Singleton)
    static let shared = ProfileService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Récupère le profil utilisateur courant
    func fetchProfile() async throws -> ProfileResponse {
        
        // URL API : utilisateur connecté
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/me")

        // Requête GET authentifiée
        return try await APIClient.shared.request(
            url: url,
            method: "GET"
        )
    }
}
