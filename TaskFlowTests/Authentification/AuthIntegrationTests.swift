//
//  AuthIntegrationTests.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/03/2026.
//

import Testing
import Foundation
@testable import TaskFlow

@Suite(.serialized)
struct AuthIntegrationTests {

    @Test
    func login_withAdminUser_returnsTokens() async throws {
        let email = ProcessInfo.processInfo.environment["TF_ADMIN_EMAIL"] ?? "admin@taskflow.com"
        let password = ProcessInfo.processInfo.environment["TF_ADMIN_PASSWORD"] ?? "PassTemp123!"

        let response = try await LoginService.shared.login(email: email, password: password)

        #expect(!response.token.isEmpty)
        #expect(!response.refreshToken.isEmpty)
    }
}

