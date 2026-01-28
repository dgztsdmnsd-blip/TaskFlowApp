//
//  UsersListService.swift
//  TaskFlow
//
//  Created by luc banchetti on 27/01/2026.
//

// UsersListService.swift

import Foundation

final class UsersListService {

    static let shared = UsersListService()
    private init() {}

    func fetchUsers() async throws -> [ProfileResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/users/liste")

        print("UsersList → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }
}


