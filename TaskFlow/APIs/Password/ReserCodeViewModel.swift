//
//  ResetCodeViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.//
//  ViewModel gérant la vérification du code
//  de réinitialisation du mot de passe.
//  Permet :
//  - De redemander un code
//  - De valider un code reçu
//  - De récupérer le token de reset
//

import Foundation
import Combine

// ViewModel de l’écran "Validation du code"
@MainActor
final class ResetCodeViewModel: ObservableObject {

    // Email concerné par la réinitialisation
    let email: String

    // Code saisi par l’utilisateur
    @Published var code = ""
    
    // Indique un appel réseau en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?
    
    // Indique une opération réussie
    @Published var isSuccess = false
    
    // Déclenche la navigation vers "Nouveau mot de passe"
    @Published var goToNewPassword = false
    
    // Token reçu après validation du code
    var resetToken: String = ""

    init(email: String) {
        self.email = email
    }

    // Validation du formulaire (code à 6 chiffres)
    var isFormValid: Bool {
        !email.isEmpty && code.count == 6
    }

    // Redemande un code de réinitialisation
    func requestCode() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.requestResetCode(email: email)
            if AppConfig.version == .dev {
                print("Backend:", response.message)
            }

            isSuccess = true

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors de l’envoi du code."

        } catch {
            errorMessage = "Erreur réseau."
        }
    }

    // Valide le code saisi et récupère le token
    func validateCode() async {
        isLoading = true
        errorMessage = nil

        // Logs debug
        if AppConfig.version == .dev {
            print("validateCode()")
            print("email:", email)
            print("code:", code)
        }

        defer { isLoading = false }

        do {
            let response = try await AuthService.shared.verifyResetCode(
                email: email,
                code: code
            )

            if AppConfig.version == .dev {
                print("Code vérifié")
                print("Token:", response.token ?? "nil")
            }
            
            // Stockage du token
            resetToken = response.token ?? ""

            // Déclenche navigation
            goToNewPassword = true
            isSuccess = true

            if AppConfig.version == .dev {
                print("Navigation déclenchée")
            }

        } catch APIError.httpError(_, let message) {
            if AppConfig.version == .dev {
                print("HTTP ERROR:", message ?? "")
            }
            errorMessage = message ?? "Code invalide"

        } catch {
            if AppConfig.version == .dev {
                print("ERROR:", error)
            }
            errorMessage = "Erreur réseau"
        }
    }
}
