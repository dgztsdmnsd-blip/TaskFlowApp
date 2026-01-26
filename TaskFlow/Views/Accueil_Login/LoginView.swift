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

    // ViewModel responsable de la logique de login
    @StateObject private var vm = LoginViewModel()

    // État global de l’application pour changer de flow
    @EnvironmentObject var appState: AppState

    // Empêche plusieurs tentatives automatiques de Face ID
    @State private var didAttemptBiometric = false

    var body: some View {
        ZStack {

            // Fond général de l’écran de login
            BackgroundView(ecran: .general)

            VStack(spacing: 20) {

                // Titre et sous-titre
                TitreView(couleur: .white, texte: "TaskFlow")
                SousTitreView(couleur: .white, texte: "Connexion")

                Spacer()

                VStack(spacing: 16) {

                    // Champ email
                    TextField("Email", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Champ mot de passe
                    SecureField("Password", text: $vm.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Message d’erreur éventuel
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Spacer()

                    // Bouton de connexion classique
                    Button {
                        Task {
                            await vm.login()

                            // En cas de succès, on bascule vers l’app principale
                            if vm.isAuthenticated {
                                appState.flow = .main
                            }
                        }
                    } label: {
                        BoutonView(
                            title: vm.isLoading
                                ? "Connexion..."
                                : "Connexion"
                        )
                    }
                    // Désactive le bouton pendant le chargement
                    .disabled(vm.isLoading)
                }
            }
            .padding()
            /// Reconnexion automatique Face ID
            .onAppear {
                guard !didAttemptBiometric else { return }
                didAttemptBiometric = true

                Task {
                    // Petit délai pour laisser la vue s’afficher
                    try? await Task.sleep(nanoseconds: 300_000_000)

                    // On tente Face ID uniquement si une session existe
                    guard SessionManager.shared.hasStoredSession else { return }

                    // Déverrouillage biométrique + refresh du token
                    await vm.loginWithBiometrics()

                    // Si la session est reconstruite, on entre dans l’app
                    if vm.isAuthenticated {
                        appState.flow = .main
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
