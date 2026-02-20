//
//  NewPasswordViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  ViewModel gérant la réinitialisation du mot de passe.
//  Permet à l’utilisateur de saisir et confirmer
//  un nouveau mot de passe via un token sécurisé.
//

import Foundation
import Combine

// ViewModel de l’écran "Nouveau mot de passe"
@MainActor
final class NewPasswordViewModel: ObservableObject {

    // Token de réinitialisation reçu par email
    let token: String
    
    // Mot de passe saisi
    @Published var password: String = ""
    
    // Confirmation du mot de passe
    @Published var password2: String = ""

    // Indique un appel réseau en cours
    @Published var isLoading = false
    
    // Indique un reset réussi
    @Published var isSuccess = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    init(token: String) {
        self.token = token
    }

    // Validation globale du formulaire
    var isFormValid: Bool {
        !password.isEmpty &&
        !password2.isEmpty &&
        password == password2 &&
        password.count >= 6
    }

    // Lance la réinitialisation du mot de passe
    func resetPassword() async {

        errorMessage = nil
        
        // Validation : champ vide
        guard !password.isEmpty else {
            errorMessage = "Veuillez saisir un mot de passe."
            return
        }

        // Validation : longueur minimale
        guard password.count >= 6 else {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }

        // Validation : correspondance
        guard password == password2 else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }

        isLoading = true

        do {
            // Appel API
            let response = try await AuthService.shared.updatePasswordWithToken(
                token: token,
                password: password
            )

            // Log debug
            if AppConfig.version == .dev {
                print("Password reset:", response.message)
            }

            // Succès
            isSuccess = true

        } catch APIError.httpError(_, let message) {
            // Erreur backend
            errorMessage = message ?? "Erreur de validation."

        } catch {
            // Erreur réseau / inconnue
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
