//
//  RegisterViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  ViewModel responsable de la logique d'inscription et de modification du profil
//

import Foundation
import Combine

enum RegisterMode {
    case create
    case edit(profile: ProfileResponse)
}

@MainActor
final class RegisterViewModel: ObservableObject {

    // Mode
    let mode: RegisterMode

    var isCreateMode: Bool {
        if case .create = mode { return true }
        return false
    }

    // Inputs
    private let userId: Int?

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var password2 = ""

    // State
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    // Init
    init(mode: RegisterMode) {
        self.mode = mode

        switch mode {
        case .create:
            self.userId = nil

        case .edit(let profile):
            self.userId = profile.id
            self.firstName = profile.firstName
            self.lastName = profile.lastName
            self.email = profile.email
        }
    }

    // Submit
    func submit() async {

        errorMessage = nil

        // Validation commune
        guard !lastName.isEmpty else {
            errorMessage = "Veuillez renseigner votre nom."
            return
        }

        guard !firstName.isEmpty else {
            errorMessage = "Veuillez renseigner votre prénom."
            return
        }

        guard !email.isEmpty else {
            errorMessage = "Veuillez renseigner votre email."
            return
        }

        // Validation création uniquement
        if isCreateMode {
            guard !password.isEmpty else {
                errorMessage = "Veuillez renseigner votre mot de passe."
                return
            }

            guard !password2.isEmpty else {
                errorMessage = "Veuillez confirmer votre mot de passe."
                return
            }

            guard password == password2 else {
                errorMessage = "Les mots de passe ne correspondent pas."
                return
            }
        }

        isLoading = true

        do {
            switch mode {

            case .create:
                _ = try await RegisterService.shared.register(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )

                // Sécurité : purge session après inscription
                SessionManager.shared.logout()

            case .edit:
                guard let userId else { return }

                // Mise à jour identité
                _ = try await RegisterService.shared.updateIdentity(
                    id: userId,
                    firstName: firstName,
                    lastName: lastName,
                    email: email
                )

                // Mise à jour mot de passe (si renseigné)
                if !password.isEmpty {
                    _ = try await RegisterService.shared.updatePassword(
                        id: userId,
                        password: password
                    )
                }
            }

            isSuccess = true

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur de validation."

        } catch {
            errorMessage = "Erreur réseau. Veuillez réessayer."
        }

        isLoading = false
    }
}
