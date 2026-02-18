//
//  NewPasswordViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation
import Combine

@MainActor
final class NewPasswordViewModel: ObservableObject {

    // Inputs

    let token: String
    @Published var password: String = ""
    @Published var password2: String = ""

    // State
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    // Init
    init(token: String) {
        self.token = token
    }

    // Validation
    var isFormValid: Bool {
        !password.isEmpty &&
        !password2.isEmpty &&
        password == password2 &&
        password.count >= 6
    }

    // Actions
    func resetPassword() async {

        errorMessage = nil
        
        guard !password.isEmpty else {
            errorMessage = "Veuillez saisir un mot de passe."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }

        guard password == password2 else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }

        isLoading = true

        do {
            let response = try await AuthService.shared.updatePasswordWithToken(
                token: token,
                password: password
            )

            print("Password reset:", response.message)


            isSuccess = true

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur de validation."

        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
