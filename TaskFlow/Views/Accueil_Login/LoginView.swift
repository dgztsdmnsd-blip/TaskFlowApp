//
//  LoginView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Vue de connexion.
//  Permet :
//  - Connexion email / mot de passe
//  - Reconnexion biométrique (Face ID)
//

import SwiftUI

struct LoginView: View {

    // Session globale injectée par l’app
    @EnvironmentObject var sessionVM: SessionViewModel

    // ViewModel local + états UI
    @StateObject private var vm: LoginViewModel
    @State private var didAttemptBiometric = false
    @State private var showForgotPassword = false

    // Initialisation
    // Injection du SessionViewModel dans le LoginViewModel
    init(sessionVM: SessionViewModel) {
        _vm = StateObject(
            wrappedValue: LoginViewModel(sessionVM: sessionVM)
        )
    }

    var body: some View {
        ZStack {

            // Background
            BackgroundView(ecran: .general)

            VStack(spacing: 20) {

                // Header
                TitreView(texte: "TaskFlow")
                SousTitreView(texte: "Connexion")

                Spacer()

                VStack(spacing: 16) {

                    // Champs de saisie

                    LabeledTextField(
                        label: "Email",
                        text: $vm.email,
                        keyboard: .emailAddress,
                        fieldId: "login.email"
                    )

                    LabeledTextField(
                        label: "Mot de passe",
                        text: $vm.password,
                        isSecure: true,
                        fieldId: "login.password"
                    )

                    // Message d’erreur
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Spacer()

                    // Bouton Connexion
                    Button {
                        Task {
                            await vm.login()
                        }
                    } label: {
                        BoutonView(
                            title: vm.isLoading
                                ? "Connexion..."
                                : "Connexion",
                            accessibilityId: "login.connexion"
                        )
                    }
                    .disabled(vm.isLoading)

                    // Mot de passe oublié
                    Button("Mot de passe oublié ?") {
                        showForgotPassword = true
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()

            // Debug Lifecycle
            .logLifecycle("LoginView")

            // Biometric Auto Login
            .onAppear {

                // Évite plusieurs tentatives
                guard !didAttemptBiometric else { return }
                didAttemptBiometric = true

                Task {

                    // Petit délai pour laisser l’UI apparaître
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    // Vérifie session stockée
                    guard SessionManager.shared.hasStoredSession else { return }

                    // Tentative Face ID / Touch ID
                    await vm.loginWithBiometrics()
                }
            }

            // Sheet Forgot Password
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}
