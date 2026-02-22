//
//  PasswordRulesView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/02/2026.
//
// Affichage des règles de mot de passe
//

import SwiftUI

struct PasswordRulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Le mot de passe doit contenir :")
            Label("Minimum 8 caractères", systemImage: "checkmark.circle")
            Label("Une majuscule", systemImage: "checkmark.circle")
            Label("Une minuscule", systemImage: "checkmark.circle")
            Label("Un chiffre", systemImage: "checkmark.circle")
            Label("Un caractère spécial", systemImage: "checkmark.circle")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
