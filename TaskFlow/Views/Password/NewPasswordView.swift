//
//  NewPasswordView.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import SwiftUI

struct NewPasswordView: View {

    let token: String

    @StateObject private var vm: NewPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    init(token: String) {
        self.token = token
        _vm = StateObject(wrappedValue: NewPasswordViewModel(token: token))
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .general)
                .ignoresSafeArea()
            
            Form {
                Section {
                    
                    SecureField("Mot de passe", text: $vm.password)
                    SecureField("Confirmation", text: $vm.password2)
                } header : {
                    Text("Nouveau mot de passe")
                        .foregroundStyle(.black)
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Réinitialiser") {
                    Task { await vm.resetPassword() }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .appNavigationTitle("Nouveau mot de passe")
        .logLifecycle("NewPasswordView")
        .onChange(of: vm.isSuccess) { _, success in
            if success {
                print("Reset SUCCESS → dismiss")
                dismiss()
                dismiss()
            }
        }
    }
}
