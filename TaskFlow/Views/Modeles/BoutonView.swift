//
//  BoutonView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Composant UI réutilisable pour les boutons principaux
//  de l’application (CTA).
//

import SwiftUI

struct BoutonView: View {

    // Texte affiché dans le bouton
    let title: String

    var body: some View {
        Text(title)

            // Largeur maximale
            .frame(maxWidth: .infinity)
            
            // Hauteur du bouton
            .frame(height: 52)
            
            // Background dégradé
            .background(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.9),
                        Color.blue.opacity(0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Couleur du texte
            .foregroundColor(.white)
            
            // Coins arrondis
            .cornerRadius(16)
            
            // Ombre
            .shadow(
                color: .black.opacity(0.2),
                radius: 10,
                y: 5
            )
    }
}


#Preview {
    BoutonView(title: "Modèle de bouton")
}
