//
//  SessionManager.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private var accessToken: String?
    private var refreshToken: String?

    func saveTokens(access: String, refresh: String) {
        self.accessToken = access
        self.refreshToken = refresh
    }

    func getAccessToken() -> String? {
        accessToken
    }

    func getRefreshToken() -> String? {
        refreshToken
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }
}

