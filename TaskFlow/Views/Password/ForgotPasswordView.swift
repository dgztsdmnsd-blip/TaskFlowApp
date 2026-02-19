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
            ZStack {
                BackgroundView(ecran: .general)
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        Text("Entrez votre adresse email pour recevoir un code de réinitialisation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    } header : {
                        Text("Récupération du mot de passe")
                            .foregroundStyle(.black)
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
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .appNavigationTitle("Mot de passe oublié")
            .logLifecycle("ForgotPasswordView")
            .navigationDestination(isPresented: $vm.goToCode) {
                ResetCodeView(email: vm.email)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
