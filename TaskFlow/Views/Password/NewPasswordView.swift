//
//  NewPasswordView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  Écran de réinitialisation du mot de passe.
//  Permet de définir un nouveau mot de passe via un token.
//

import SwiftUI

struct NewPasswordView: View {

    // Token reçu depuis l’étape précédente
    let token: String

    // ViewModel local + dismiss de la vue
    @StateObject private var vm: NewPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    // Initialisation
    // Injection du token dans le ViewModel
    init(token: String) {
        self.token = token
        _vm = StateObject(
            wrappedValue: NewPasswordViewModel(token: token)
        )
    }

    var body: some View {
        ZStack {

            // Background
            BackgroundView(ecran: .general)
                .ignoresSafeArea()

            // Formulaire
            Form {

                // Section Password
                Section {

                    SecureField("Mot de passe", text: $vm.password)
                    SecureField("Confirmation", text: $vm.password2)

                } header: {
                    Text("Nouveau mot de passe")
                        .adaptiveTextColor()
                }

                // Message d’erreur
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                // Action Reset
                Button("Réinitialiser") {
                    Task { await vm.resetPassword() }
                }
            }
        }
        // Style Form
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        // Navigation Title
        .appNavigationTitle("Nouveau mot de passe")
        // Debug Lifecycle
        .logLifecycle("NewPasswordView")
        // Success Handling
        .onChange(of: vm.isSuccess) { _, success in
            if success {
                if AppConfig.version == .dev {
                    print("Reset SUCCESS → dismiss")
                }

                // Double dismiss :
                // utile si NewPasswordView est dans une NavigationStack
                // présentée elle-même dans une Sheet
                dismiss()
                dismiss()
            }
        }
    }
}
