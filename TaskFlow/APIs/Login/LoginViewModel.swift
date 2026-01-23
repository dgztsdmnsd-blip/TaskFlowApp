//
//  LoginViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    @Published var token: String?
    @Published var refreshToken: String?

    func login() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await LoginService.shared.login(
                email: email,
                password: password
            )

            // Sauvegarde des tokens
            SessionManager.shared.saveTokens(
                access: response.token,
                refresh: response.refreshToken
            )

            self.token = response.token
            self.refreshToken = response.refreshToken

            self.isAuthenticated = true
            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

}

