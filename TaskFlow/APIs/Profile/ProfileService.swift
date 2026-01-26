//
//  ProfileService.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Service réseau responsable de la récupération
//  des informations du profil utilisateur connecté.
//

import Foundation

final class ProfileService {

    static let shared = ProfileService()
    private init() {}

    func fetchProfile() async throws -> ProfileResponse {
        let url = AppConfig.baseURL.appendingPathComponent("/api/users/me")

        return try await APIClient.shared.request(
            url: url,
            method: "GET"
        )
    }
}

