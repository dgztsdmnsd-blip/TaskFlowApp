//
//  ReserCodeViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation
import Combine

@MainActor
final class ResetCodeViewModel: ObservableObject {

    let email: String

    @Published var code = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    @Published var goToNewPassword = false
    
    var resetToken: String = ""

    init(email: String) {
        self.email = email
    }

    var isFormValid: Bool {
        !email.isEmpty && code.count == 6
    }

    // Actions
    func requestCode() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.requestResetCode(email: email)
            print("Backend:", response.message)

            isSuccess = true

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors de l’envoi du code."

        } catch {
            errorMessage = "Erreur réseau."
        }
    }

    func validateCode() async {
        isLoading = true
        errorMessage = nil

        print("validateCode()")
        print("email:", email)
        print("code:", code)

        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.verifyResetCode(
                email: email,
                code: code
            )

            print("Code vérifié")
            print("Token:", response.token ?? "nil")

            resetToken = response.token ?? ""

            goToNewPassword = true
            isSuccess = true

            print("Navigation déclenchée")

        } catch APIError.httpError(_, let message) {
            print("HTTP ERROR:", message ?? "")
            errorMessage = message ?? "Code invalide"

        } catch {
            print("ERROR:", error)
            errorMessage = "Erreur réseau"
        }
    }

}
