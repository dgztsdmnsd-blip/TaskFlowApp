//
//  ForgotPasswordViewModel.swift
//  TaskFlow
//
//  ViewModel gérant la logique de demande
//  de réinitialisation du mot de passe.
//  Permet d’envoyer un code à l’adresse email.
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation
import Combine

// ViewModel de l’écran "Mot de passe oublié"
@MainActor
final class ForgotPasswordViewModel: ObservableObject {

    // Email saisi par l’utilisateur
    @Published var email = ""
    
    // Indique un appel réseau en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?
    
    // Déclenche la navigation vers l’écran du code
    @Published var goToCode = false

    // Envoie le code de réinitialisation
    func sendCode() async {
        errorMessage = nil
        isLoading = true

        do {
            // Appel API
            let response = try await AuthService.shared.requestResetCode(email: email)
            
            // Log debug
            if AppConfig.version == .dev {
                print("Reset code requested:", response.message)
            }

            // Navigation vers l’écran suivant
            goToCode = true
            
        } catch APIError.httpError(_, let message) {
            // Erreur backend (ex: email invalide)
            errorMessage = message ?? "Email invalide"
            
        } catch {
            // Erreur réseau / inconnue
            errorMessage = "Erreur réseau"
        }

        isLoading = false
    }
}
