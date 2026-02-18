//
//  ForgotPasswordView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import SwiftUI

struct ForgotPasswordView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ForgotPasswordViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Récupération du mot de passe") {
                    Text("Entrez votre adresse email pour recevoir un code de réinitialisation.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Email", text: $vm.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

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
            .navigationTitle("Mot de passe oublié")
            .logLifecycle("ForgotPasswordView")
            .navigationDestination(isPresented: $vm.goToCode) {
                ResetCodeView(email: vm.email)
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
