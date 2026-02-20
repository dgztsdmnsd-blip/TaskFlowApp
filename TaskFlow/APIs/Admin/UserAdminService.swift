//
//  UserAdminService.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//
//  Service utilisé par l’interface d’administration.
//  Permet de modifier un utilisateur :
//  - Statut (actif, suspendu, etc.)
//  - Profil / rôle (user, admin, etc.)
//


import Foundation

// Service d’administration des utilisateurs
final class UserAdminService {

    // Instance partagée (Singleton)
    static let shared = UserAdminService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Met à jour un utilisateur (statut / profil)
    func updateUser(
        id: Int,
        status: AdminUserStatus? = nil,
        profil: AdminUserProfil? = nil
    ) async throws -> ProfileResponse {

        // Construction de l’URL API
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/admin/update/\(id)")

        // Payload envoyé au backend
        var payload: [String: String] = [:]

        // Ajout du statut si fourni
        if let status {
            payload["status"] = status.rawValue
        }

        // Ajout du profil si fourni
        if let profil {
            payload["profil"] = profil.rawValue
        }

        // Logs debug
        if AppConfig.version == .dev {
            print("ADMIN url:", url.absoluteString)
            print("ADMIN PATCH PAYLOAD:", payload)
        }

        // Requête PATCH authentifiée
        return try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: payload,
            requiresAuth: true
        )
    }
}
