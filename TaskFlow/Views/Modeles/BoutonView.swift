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
    let title: String

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
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
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}


#Preview {
    BoutonView(title: "Modèle de bouton")
}
