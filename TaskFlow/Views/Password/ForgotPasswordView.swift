//
//  ForgotPasswordView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  Écran de récupération du mot de passe.
//  Permet d’envoyer un code de réinitialisation par email.
//

import SwiftUI

struct ForgotPasswordView: View {

    // Permet de fermer la sheet
    @Environment(\.dismiss) private var dismiss

    // ViewModel local + état UI
    @StateObject private var vm = ForgotPasswordViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                // Background
                BackgroundView(ecran: .general)
                    .ignoresSafeArea()

                // Formulaire
                Form {

                    // Section Instructions + Email
                    Section {

                        Text("Entrez votre adresse email pour recevoir un code de réinitialisation.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                    } header: {
                        Text("Récupération du mot de passe")
                            .adaptiveTextColor()
                    }

                    // Message d’erreur
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Section Action
                    Section {

                        Button {
                            Task { await vm.sendCode() }
                        } label: {

                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Text("Envoyer le code")
                                    .bold()
                            }
                        }
                        .disabled(vm.email.isEmpty || vm.isLoading)
                    }
                }
            }
            // Style Form
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            // Navigation Title
            .appNavigationTitle("Mot de passe oublié")
            // Debug Lifecycle
            .logLifecycle("ForgotPasswordView")
            // Navigation vers ResetCodeView
            .navigationDestination(isPresented: $vm.goToCode) {
                ResetCodeView(email: vm.email)
            }
            // Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    // Bouton fermeture
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.app.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
