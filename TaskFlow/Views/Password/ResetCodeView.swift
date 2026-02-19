//
//  ResetCodeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import SwiftUI

struct ResetCodeView: View {

    let email: String
    @StateObject private var vm: ResetCodeViewModel

    init(email: String) {
        self.email = email
        _vm = StateObject(wrappedValue: ResetCodeViewModel(email: email))
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .general)
                .ignoresSafeArea()
            
            Form {
                Section {
                    
                    Text("Entrez le code à 6 chiffres envoyé à \(email)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("123456", text: $vm.code)
                        .keyboardType(.numberPad)
                } header : {
                    Text("Code reçu par email")
                        .foregroundStyle(.black)
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button("Vérifier") {
                    Task { await vm.validateCode() }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .appNavigationTitle("Validation du code")
        .logLifecycle("ResetCodeView")
        .navigationDestination(isPresented: $vm.goToNewPassword) {
            NewPasswordView(token: vm.resetToken)
        }
    }
}

