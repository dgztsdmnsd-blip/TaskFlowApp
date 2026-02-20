//
//  Fields.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//
//  Composants UI réutilisables pour les champs de saisie
//  (TextField / SecureField) avec label.
//

import SwiftUI

// Champ avec label (texte ou sécurisé)
struct LabeledTextField: View {

    // Texte du label affiché au-dessus du champ
    let label: String
    
    // Binding vers la valeur saisie
    @Binding var text: String

    // Type de clavier (email, nombre, etc.)
    var keyboard: UIKeyboardType = .default
    
    // Détermine si le champ est sécurisé (mot de passe)
    var isSecure: Bool = false
    
    // Gestion de la capitalisation automatique
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Label en majuscules
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            // Champ sécurisé ou standard
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
        // Petit espacement vertical
        .padding(.vertical, 2)
    }
}

// Style commun aux champs
extension View {

    func formFieldStyle() -> some View {
        self
        
            // Padding interne
            .padding(10)
            
            // Fond léger type formulaire iOS
            .background(Color(.systemGray6))
            
            // Coins arrondis
            .cornerRadius(8)
    }
}

// Preview SwiftUI
#Preview {
    VStack(spacing: 16) {
        
        // Exemple champ email
        LabeledTextField(
            label: "Email",
            text: .constant("test@email.com"),
            keyboard: .emailAddress
        )

        // Exemple champ mot de passe
        LabeledTextField(
            label: "Mot de passe",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
}
