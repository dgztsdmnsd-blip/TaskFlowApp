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

import SwiftUI

@MainActor
struct RegisterView: View {

    // Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var session: SessionViewModel

    // State
    @State private var showAlert = false
    @StateObject private var vm: RegisterViewModel

    // Init
    init(mode: RegisterMode) {
        _vm = StateObject(wrappedValue: RegisterViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView(ecran: .users)

                Form {

                    // --------------------
                    // Identité
                    // --------------------
                    Section("Identité") {
                        LabeledTextField(label: "Nom", text: $vm.lastName)
                        LabeledTextField(label: "Prénom", text: $vm.firstName)
                        LabeledTextField(
                            label: "Email",
                            text: $vm.email,
                            keyboard: .emailAddress
                        )
                    }

                    // --------------------
                    // Mot de passe (création)
                    // --------------------
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

                    // --------------------
                    // Erreur
                    // --------------------
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.vertical, 4)
                    }

                    // --------------------
                    // Action
                    // --------------------
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
                                // REFRESH SESSION
                                await session.refreshCurrentUser()
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
}
