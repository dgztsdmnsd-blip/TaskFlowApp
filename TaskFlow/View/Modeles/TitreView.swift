//
//  TitreView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct TitreView: View {
    let couleur: Color
    let texte: String
    
    var body: some View {
        Text(texte)
            .font(.largeTitle.bold())
            .foregroundStyle(couleur)
    }
}

#Preview {
    TitreView(couleur: .blue, texte: "Bienvenue")
}
