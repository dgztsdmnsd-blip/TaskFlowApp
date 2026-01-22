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

            // Récupération des token depuis la réponse
            self.token = response.token
            self.refreshToken = response.refreshToken
            
            errorMessage = nil
        } catch {
            // Gestion d'erreur
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

