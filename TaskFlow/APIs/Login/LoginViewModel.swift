//
//  LoginViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  ViewModel responsable de la logique de connexion :
//  - login classique (email / mot de passe)
//  - reconnexion via Face ID (refresh token)
//

import Foundation
import Combine
import LocalAuthentication

@MainActor
final class LoginViewModel: ObservableObject {

    // Email saisi par l’utilisateur
    @Published var email = ""

    // Mot de passe saisi par l’utilisateur
    @Published var password = ""

    // Indique qu’un appel de login est en cours
    @Published var isLoading = false

    // Indique si l’utilisateur est authentifié avec succès
    @Published var isAuthenticated = false

    // Message d’erreur affichable dans la vue
    @Published var errorMessage: String?

    // Empêche les appels concurrents à Face ID
    @Published var isAuthenticatingWithBiometrics = false


    // Login classique (email / mot de passe)
    /// Authentification classique via l’API.
    /// Cette méthode :
    /// - valide les champs
    /// - appelle l’endpoint de login
    /// - démarre une session complète (tokens)
    /// - met à jour l’état observé par la vue
    func login() async {

        // Début du chargement
        isLoading = true
        errorMessage = nil
        isAuthenticated = false

        // Validation locale : email requis
        guard !email.isEmpty else {
            errorMessage = "Veuillez renseigner votre email."
            isLoading = false
            return
        }

        // Validation locale : mot de passe requis
        guard !password.isEmpty else {
            errorMessage = "Veuillez renseigner votre mot de passe."
            isLoading = false
            return
        }

        do {
            // Appel API de login
            let response = try await LoginService.shared.login(
                email: email,
                password: password
            )

            // Démarrage de la session :
            // - access token en mémoire
            // - refresh token sécurisé (Keychain + Face ID)
            try SessionManager.shared.startSession(
                email: email,
                accessToken: response.token,
                refreshToken: response.refreshToken
            )

            // Succès → l’UI peut naviguer vers MainView
            isAuthenticated = true

        } catch APIError.unauthorized(let message) {
            // Identifiants incorrects
            errorMessage = message ?? "Identifiants incorrects"

        } catch APIError.httpError(_, let message) {
            // Erreur serveur renvoyée par l’API
            errorMessage = message ?? "Erreur serveur"

        } catch {
            // Erreur réseau ou inconnue
            errorMessage = "Erreur réseau"
        }

        // Fin du chargement
        isLoading = false
    }

    // Login biométrique (Face ID / Touch ID)
    /// Reconnexion sécurisée via Face ID.
    /// Cette méthode :
    /// - déverrouille le refresh token (Keychain)
    /// - appelle l’API de refresh
    /// - restaure l’access token
    /// - reconstruit la session sans login manuel
    func loginWithBiometrics() async {

        // Empêche toute tentative concurrente
        guard !isAuthenticatingWithBiometrics else { return }
        isAuthenticatingWithBiometrics = true
        defer { isAuthenticatingWithBiometrics = false }

        errorMessage = nil
        isAuthenticated = false

        do {
            // Déverrouillage du refresh token
            // déclenche Face ID
            let refreshToken = try SessionManager.shared.getRefreshToken()

            // Succès → l’UI peut naviguer vers MainView
            isAuthenticated = true

        } catch {
            // Refresh impossible (token invalide, supprimé, etc.)
            errorMessage = "Session invalide, reconnectez-vous"
        }
    }
}
