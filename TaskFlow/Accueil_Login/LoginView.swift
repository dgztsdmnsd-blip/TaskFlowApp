//
//  LoginView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var vm = LoginViewModel()

    var body: some View {
        ZStack {
            // fond
            BackgroundView()

            VStack(spacing: 20) {
                // Titre
                TitreView(couleur: .white, texte: "TaskFlow")
                //Sous Titre
                SousTitreView(couleur: .white, texte: "Connexion")

                Spacer()

                VStack(spacing: 16) {

                    // Email
                    TextField("Email", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    SecureField("Password", text: $vm.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Temporaire
                    if let token = vm.token {
                        Text("Token récupéré")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Spacer ()

                    // Connexion
                    Button {
                        Task {
                            await vm.login()
                        }
                    } label: {
                        BoutonView(title: vm.isLoading ? "Connexion..." : "Connexion")
                    }
                    .disabled(vm.isLoading)
                }

                Spacer()
            }
            .padding()
        }
    }
}


#Preview {
    LoginView()
}
