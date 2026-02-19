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
    let texte: String
    
    var body: some View {
        Text(texte)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.black.opacity(0.9))
            .multilineTextAlignment(.center)
    }
}

#Preview {
    SousTitreView(texte: "Bienvenue")
}
