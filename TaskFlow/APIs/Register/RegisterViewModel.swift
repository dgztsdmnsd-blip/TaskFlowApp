//
//  RegisterViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  ViewModel responsable de la logique d'inscription :
//  - login classique (email / mot de passe)
//  - reconnexion via Face ID (refresh token)
//

import Foundation
import Combine


@MainActor
final class RegisterViewModel: ObservableObject {
    
    // Prénom saisi par l’utilisateur
    @Published var firstName = ""
    
    // Nom saisi par l’utilisateur
    @Published var lastName = ""
    
    // Email saisi par l’utilisateur
    @Published var email = ""

    // Mot de passe saisi par l’utilisateur
    @Published var password = ""
    
    // Confirmation du Mot de passe saisi par l’utilisateur
    @Published var password2 = ""

    @Published var isLoading = false
    @Published var isRegistered = false
    @Published var errorMessage: String?
    @Published var register: RegisterResponse?
    
    private let registerAction: (
            String, String, String, String
        ) async throws -> RegisterResponse

    init(
        registerAction: @escaping (
            String, String, String, String
        ) async throws -> RegisterResponse
    ) {
        self.registerAction = registerAction
    }
    
    convenience init() {
        self.init(registerAction: RegisterService.shared.register)
    }
    
    /// Récupère le profil de l’utilisateur connecté depuis l’API.
    func fetchRegister() async {        
        // Validation locale : email requis
        guard !lastName.isEmpty else {
            errorMessage = "Veuillez renseigner votre nom."
            return
        }
        
        // Validation locale : email requis
        guard !firstName.isEmpty else {
            errorMessage = "Veuillez renseigner votre prénom."
            return
        }
        
        // Validation locale : email requis
        guard !email.isEmpty else {
            errorMessage = "Veuillez renseigner votre email."
            return
        }

        // Validation locale : mot de passe requis
        guard !password.isEmpty else {
            errorMessage = "Veuillez renseigner votre mot de passe."
            return
        }
        
        // Validation locale : confirmation mot de passe requis
        guard !password2.isEmpty else {
            errorMessage = "Veuillez confirmer votre mot de passe."
            return
        }
        
        // Confirmation du password
        guard password == password2 else {
            errorMessage = "Le mot de passe n'est pas égal à la confirmation."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            register = try await registerAction(
                firstName,
                lastName,
                email,
                password
            )
            
            // Nettoyage complet après inscription
            SessionManager.shared.logout()
            
            isRegistered = true

        } catch APIError.httpError(_, let message) {
            // Message renvoyé par le backend (validation, email déjà utilisé, etc.)
            print("Erreur: \(message ?? "")")
            errorMessage = message ?? "Erreur de validation."

        } catch {
            // Erreur réseau, timeout, etc.
            errorMessage = "Erreur réseau. Veuillez réessayer."
        }


        isLoading = false
    }
}

