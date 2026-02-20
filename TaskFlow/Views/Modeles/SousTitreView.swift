//
//  SousTitreView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Composant UI réutilisable pour afficher
//  les sous-titres et textes d’introduction.
//

import SwiftUI

struct SousTitreView: View {

    // Texte affiché
    let texte: String
    
    var body: some View {
        Text(texte)
        
            // Style typographique sous-titre
            .font(.title3)
            .fontWeight(.medium)
            
            // Couleur adaptative (Light / Dark)
            .adaptiveTextColor()
            
            // Alignement centré (multi-lignes)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    SousTitreView(texte: "Bienvenue")
}
