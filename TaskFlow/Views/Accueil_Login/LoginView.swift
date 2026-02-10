//
//  LoginView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Vue de connexion de l’application.
//  Elle permet :
//  - une connexion classique (email / mot de passe)
//  - une reconnexion automatique via Face ID
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var sessionVM: SessionViewModel

    @StateObject private var vm: LoginViewModel
    @State private var didAttemptBiometric = false

    init(sessionVM: SessionViewModel) {
        _vm = StateObject(
            wrappedValue: LoginViewModel(sessionVM: sessionVM)
        )
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .general)

            VStack(spacing: 20) {
                TitreView(couleur: .white, texte: "TaskFlow")
                SousTitreView(couleur: .white, texte: "Connexion")

                Spacer()

                VStack(spacing: 16) {

                    LabeledTextField(
                        label: "Email",
                        text: $vm.email,
                        keyboard: .emailAddress
                    )

                    LabeledTextField(
                        label: "Mot de passe",
                        text: $vm.password,
                        isSecure: true
                    )

                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Spacer()

                    Button {
                        Task {
                            await vm.login()
                        }
                    } label: {
                        BoutonView(
                            title: vm.isLoading
                                ? "Connexion..."
                                : "Connexion"
                        )
                    }
                    .disabled(vm.isLoading)
                }
            }
            .padding()
            .onAppear {
                guard !didAttemptBiometric else { return }
                didAttemptBiometric = true

                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    guard SessionManager.shared.hasStoredSession else { return }

                    await vm.loginWithBiometrics()
                }
            }
        }
    }
}

