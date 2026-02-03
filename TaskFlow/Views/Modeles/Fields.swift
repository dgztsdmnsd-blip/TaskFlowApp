//
//  Fields.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//

import SwiftUI

// Labeled Text / Secure Field
struct LabeledTextField: View {

    let label: String
    @Binding var text: String

    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            if isSecure {
                SecureField(label, text: $text)
                    .formFieldStyle()
            } else {
                TextField(label, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autocapitalization)
                    .formFieldStyle()
            }
        }
        .padding(.vertical, 2)
    }
}

// Shared Field Style
extension View {
    func formFieldStyle() -> some View {
        self
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

// Preview
#Preview {
    VStack(spacing: 16) {
        LabeledTextField(
            label: "Email",
            text: .constant("test@email.com"),
            keyboard: .emailAddress
        )

        LabeledTextField(
            label: "Mot de passe",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
}
