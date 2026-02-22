//
//  RegisterView.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  Vue d'enregistrement / édition profil utilisateur.
//

import SwiftUI

@MainActor
struct RegisterView: View {

    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss
    
    // État global de navigation
    @EnvironmentObject private var appState: AppState
    
    // Session utilisateur
    @EnvironmentObject private var session: SessionViewModel

    // Contrôle l’alerte succès
    @State private var showAlert = false
    
    // ViewModel formulaire
    @StateObject private var vm: RegisterViewModel

    // Init
    init(mode: RegisterMode) {
        _vm = StateObject(
            wrappedValue: RegisterViewModel(mode: mode)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond dégradé écran Users
                BackgroundView(ecran: .users)
                    .ignoresSafeArea()

                Form {

                    // Section Identité
                    Section {
                        LabeledTextField(label: "Nom", text: $vm.lastName)
                        LabeledTextField(label: "Prénom", text: $vm.firstName)
                        LabeledTextField(
                            label: "Email",
                            text: $vm.email,
                            keyboard: .emailAddress
                        )
                    } header : {
                        Text("Identité")
                            .adaptiveTextColor()
                    }

                    // Mot de passe (création)
                    if vm.isCreateMode {
                        Section {
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
                        } header : {
                            Text("Mot de passe")
                                .adaptiveTextColor()
                        }
                        
                        Section {
                            PasswordRulesView()
                                .padding(.vertical, 4)

                        } header: {
                            Text("Sécurité")
                                .adaptiveTextColor()
                        }
                    }

                    // Mot de passe (édition)
                    if !vm.isCreateMode {
                        Section {

                            LabeledTextField(
                                label: "Nouveau mot de passe",
                                text: $vm.password,
                                isSecure: true
                            )

                            LabeledTextField(
                                label: "Confirmation",
                                text: $vm.password2,
                                isSecure: true
                            )

                            // Info UX
                            Text("Laissez vide pour conserver le mot de passe actuel.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Section {
                                PasswordRulesView()
                                    .padding(.vertical, 4)

                            } header: {
                                Text("Sécurité")
                                    .adaptiveTextColor()
                            }

                        } header : {
                            Text("Changer le mot de passe")
                                .adaptiveTextColor()
                        }
                    }

                    // Message d’erreur
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.vertical, 4)
                    }

                    // Bouton Action
                    Button {
                        Task {
                            await vm.submit()
                            
                            // Succès → affiche alerte
                            if vm.isSuccess {
                                showAlert = true
                            }
                        }
                    } label: {
                        BoutonView(
                            title: vm.isLoading
                                ? "Traitement..."
                                : (vm.isCreateMode
                                    ? "Créer le compte"
                                    : "Enregistrer")
                        )
                    }
                    .disabled(vm.isLoading)
                }
                // Supprime le fond gris Form
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                // Titre navigation dynamique
                .appNavigationTitle(
                    vm.isCreateMode
                        ? "Inscription"
                        : "Modifier le profil"
                )
                // Debug lifecycle
                .logLifecycle("RegisterView")
                // Bouton fermeture (mode édition)
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
                // Alerte succès
                .alert(
                    vm.isCreateMode ? "Compte créé" : "Profil mis à jour",
                    isPresented: $showAlert
                ) {
                    Button("OK") {
                        Task {
                            if vm.isCreateMode {
                                
                                // Redirection login
                                appState.flow = .loginForm
                                
                            } else {
                                
                                // Refresh session
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
