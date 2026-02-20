//
//  TitreView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Composant UI réutilisable pour afficher
//  les titres principaux de l’application.
//

import SwiftUI

struct TitreView: View {

    // Texte du titre
    let texte: String
    
    var body: some View {
        Text(texte)
            // Style typographique principal
            .font(.largeTitle.bold())
            // Couleur adaptative (Light / Dark)
            .adaptiveTextColor()
    }
}

#Preview {
    TitreView(texte: "Bienvenue")
}
