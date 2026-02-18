//
//  ForgotPasswordViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation
import Combine

@MainActor
final class ForgotPasswordViewModel: ObservableObject {

    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var goToCode = false

    func sendCode() async {
        errorMessage = nil
        isLoading = true

        do {
            let response = try await AuthService.shared.requestResetCode(email: email)
            print("Reset code requested:", response.message)

            goToCode = true
        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Email invalide"
        } catch {
            errorMessage = "Erreur réseau"
        }

        isLoading = false
    }
}
