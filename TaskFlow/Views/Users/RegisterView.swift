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
    // ViewModel responsable de la logique de Register
    @StateObject private var rm = RegisterViewModel()
    
    @EnvironmentObject var appState: AppState
    
    @State private var showSuccessAlert = false

    
    var body: some View {
        NavigationStack {
                
            Form {
                
                Section ("Identité"){
                    registerField("Nom", text: $rm.lastName)
                    
                    registerField("Prénom", text: $rm.firstName)
                    
                    // Champ email
                    registerField("Email", text: $rm.email)
                }

                Section ("Mot de passe"){
                    // Champ mot de passe
                    registerSecureField("Password", text: $rm.password)
                    
                    // Champ de confirmation du mot de passe
                    registerSecureField("Confirmer le Password", text: $rm.password2)
                }
                
                // Message d’erreur éventuel
                if let error = rm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                
                // Bouton d'enregistrement
                Button {
                    Task {
                        await rm.fetchRegister()

                        if rm.isRegistered {
                            // PopUp de succés de l'enregistrement
                            showSuccessAlert = true
                        }
                    }
                } label: {
                    BoutonView(
                        title: rm.isLoading
                            ? "Enregistrement en cours..."
                            : "Enregistrer"
                    )
                }
                .disabled(rm.isLoading)

            }
            .navigationTitle("Inscription")
            .alert("Compte créé", isPresented: $showSuccessAlert) {
                Button("Se connecter") {
                    // Redirection à l'écran de Login
                    appState.flow = .loginForm
                }
            } message: {
                Text("Votre compte a été créé avec succès. Vous pouvez maintenant vous connecter.")
            }

        }
    }
    
    /// Affichage d'une ligne
    private func registerField(
        _ label: String,
        text: Binding<String>
    ) -> some View {
        TextField(label, text: text)
            .textInputAutocapitalization(.never)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.vertical, 4)
    }
    
    
    /// Affichage d'une ligne
    private func registerSecureField(
        _ label: String,
        text: Binding<String>
    ) -> some View {
        SecureField(label, text: text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }

    
}

#Preview {
    RegisterView()
}
