//
//  RegisterView.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  Vue d'enregistrement à l’application.
//  Elle permet :
//  - de s'inscrire avec redirection vers la connexion
//  - consulter les messages d'erreur de l'inscription
//  - vider la mémoire
//

//
//  RegisterView.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//

import SwiftUI

@MainActor
struct RegisterView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    // MARK: - State
    @State private var showAlert = false
    @StateObject private var vm: RegisterViewModel

    // VM partagé pour reload du profil
    let profileViewModel: ProfileViewModel?

    // MARK: - Init
    init(
        mode: RegisterMode,
        profileViewModel: ProfileViewModel? = nil
    ) {
        _vm = StateObject(wrappedValue: RegisterViewModel(mode: mode))
        self.profileViewModel = profileViewModel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Identité
                Section("Identité") {
                    LabeledTextField(label: "Nom", text: $vm.lastName)
                    LabeledTextField(label: "Prénom", text: $vm.firstName)
                    LabeledTextField(
                        label: "Email",
                        text: $vm.email,
                        keyboard: .emailAddress
                    )
                }

                // MARK: - Mot de passe (création uniquement)
                if vm.isCreateMode {
                    Section("Mot de passe") {
                        LabeledTextField(
                            label: "Mot de passe",
                            text: $vm.password,
                            isSecure: true
                        )

                        LabeledTextField(
                            label: "Confirmation",
                            text: $vm.password2,
                            isSecure: true
                        )
                    }
                }

                // MARK: - Erreur
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.vertical, 4)
                }

                // Enregistrement
                Button {
                    Task {
                        await vm.submit()
                        if vm.isSuccess {
                            showAlert = true
                        }
                    }
                } label: {
                    BoutonView(
                        title: vm.isLoading
                        ? "Traitement..."
                        : (vm.isCreateMode ? "Créer le compte" : "Enregistrer")
                    )
                }
                .disabled(vm.isLoading)
            }
            .navigationTitle(
                vm.isCreateMode ? "Inscription" : "Modifier le profil"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !vm.isCreateMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.app.fill")
                        }
                        .accessibilityLabel("Fermer")
                    }
                }
            }
            .alert(
                vm.isCreateMode ? "Compte créé" : "Profil mis à jour",
                isPresented: $showAlert
            ) {
                Button("OK") {
                    Task {
                        if vm.isCreateMode {
                            appState.flow = .loginForm
                        } else {
                            // reload profil
                            await profileViewModel?.reloadProfile()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text(
                    vm.isCreateMode
                    ? "Votre compte a été créé avec succès."
                    : "Votre profil a été mis à jour."
                )
            }
        }
    }
}
