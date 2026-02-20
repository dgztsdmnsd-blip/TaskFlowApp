//
//  UsersListService.swift
//  TaskFlow
//
//  Created by luc banchetti on 27/01/2026.
//
//  Service réseau responsable de la récupération
//  de la liste des utilisateurs.
//

import Foundation

// Service de récupération des utilisateurs
final class UsersListService {

    // Instance partagée (Singleton)
    static let shared = UsersListService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Récupère la liste des utilisateurs
    func fetchUsers() async throws -> [ProfileResponse] {

        // URL API
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/liste")

        // Log debug
        if AppConfig.version == .dev {
            print("UsersList → URL:", url)
        }

        // Requête GET authentifiée
        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }
}
