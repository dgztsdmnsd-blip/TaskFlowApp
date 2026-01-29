//
//  UserAdminService.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//
//  Modèle représentant la modification d'un utilisateur par un admin
//  - Statut
//  - Profil
//

import Foundation

final class UserAdminService {

    static let shared = UserAdminService()
    private init() {}

    func updateUser(
        id: Int,
        status: AdminUserStatus? = nil,
        profil: AdminUserProfil? = nil
    ) async throws -> ProfileResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/admin/update/\(id)")

        var payload: [String: String] = [:]

        if let status {
            payload["status"] = status.rawValue
        }

        if let profil {
            payload["profil"] = profil.rawValue
        }

        print("ADMIN url:", url.absoluteString)
        print("ADMIN PATCH PAYLOAD:", payload)

        return try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: payload,
            requiresAuth: true
        )
    }
}
