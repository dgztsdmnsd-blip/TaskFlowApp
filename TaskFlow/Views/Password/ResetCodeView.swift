//
//  ResetCodeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  Écran de validation du code.
//  Permet de vérifier le code reçu par email
//  avant la création d’un nouveau mot de passe.
//

import SwiftUI

struct ResetCodeView: View {

    // Email transmis depuis ForgotPasswordView
    let email: String

    // ViewModel local lié à cet écran
    @StateObject private var vm: ResetCodeViewModel

    // Initialisation
    // Injection de l’email dans le ViewModel
    init(email: String) {
        self.email = email
        _vm = StateObject(
            wrappedValue: ResetCodeViewModel(email: email)
        )
    }

    var body: some View {
        ZStack {

            // Background
            BackgroundView(ecran: .general)
                .ignoresSafeArea()

            // Formulaire
            Form {

                // Section Instructions + Code
                Section {

                    Text("Entrez le code à 6 chiffres envoyé à \(email)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("123456", text: $vm.code)
                        .keyboardType(.numberPad)

                } header: {
                    Text("Code reçu par email")
                        .adaptiveTextColor()
                }

                // Message d’erreur
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Action Vérification
                Button("Vérifier") {
                    Task { await vm.validateCode() }
                }
            }
        }
        // Style Form
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        // Navigation Title
        .appNavigationTitle("Validation du code")
        // Debug Lifecycle
        .logLifecycle("ResetCodeView")
        // Navigation vers NewPasswordView
        .navigationDestination(isPresented: $vm.goToNewPassword) {
            NewPasswordView(token: vm.resetToken)
        }
    }
}
