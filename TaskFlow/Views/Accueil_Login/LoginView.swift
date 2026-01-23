//
//  LoginView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var vm = LoginViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            BackgroundView(ecran: .general)

            VStack(spacing: 20) {
                TitreView(couleur: .white, texte: "TaskFlow")
                SousTitreView(couleur: .white, texte: "Connexion")

                Spacer()

                VStack(spacing: 16) {

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

                    Spacer()

                    Button {
                        Task {
                            await vm.login()
                            appState.flow = .main
                        }
                    } label: {
                        BoutonView(
                            title: vm.isLoading ? "Connexion..." : "Connexion"
                        )
                    }
                    .disabled(vm.isLoading)
                }
            }
            .padding()
        }
    }
}


#Preview {
    LoginView()
}
