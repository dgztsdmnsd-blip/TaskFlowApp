//
//  BoutonImageView.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/02/2026.
//
//  Bouton stylisé avec icône SF Symbol
//

import SwiftUI

struct BoutonImageView: View {

    // Styles visuels disponibles
    enum Style {
        case primary
        case secondary
        case success
        case danger

        // Gradient associé au style
        var gradient: LinearGradient {
            switch self {

            // Style principal (actions importantes)
            case .primary:
                return LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.55, blue: 0.85),
                        Color(red: 0.25, green: 0.45, blue: 0.75)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
            // Style secondaire (actions neutres)
            case .secondary:
                return LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.82, blue: 0.95),
                        Color(red: 0.58, green: 0.74, blue: 0.90)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

            // Style succès (création / validation)
            case .success:
                return LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.80, blue: 0.65),
                        Color(red: 0.40, green: 0.70, blue: 0.55)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

            // Style danger (suppression / actions critiques)
            case .danger:
                return LinearGradient(
                    colors: [
                        Color(red: 0.80, green: 0.45, blue: 0.45),
                        Color(red: 0.70, green: 0.35, blue: 0.35)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }

    // Texte du bouton
    let title: String
    
    // Icône SF Symbol
    let systemImage: String
    
    // Style visuel
    let style: Style
    
    // Action au tap
    let action: () -> Void
    
    // Reconnaitre le champ dans les tests UI
    var accessibilityId: String? = nil

    var body: some View {
        Button(action: action) {

            // Label texte + icône
            Label(title, systemImage: systemImage)
                .font(.headline)
                
                // Largeur max
                .frame(maxWidth: .infinity)
                
                // Hauteur fixe
                .frame(height: 40)
                
                // Background gradient
                .background(style.gradient)
                
                // Couleur texte
                .foregroundColor(.white)
                
                // Coins arrondis
                .cornerRadius(14)
                
                // Ombre légère
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 6,
                    y: 3
                )
        }
        // Supprime le style bouton par défaut
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityId ?? "")
    }
}


#Preview {
    VStack(spacing: 16) {

        // Bouton primary
        BoutonImageView(
            title: "Action standard",
            systemImage: "arrow.right",
            style: .primary
        ) {}

        // Bouton success
        BoutonImageView(
            title: "Créer le projet",
            systemImage: "folder.badge.plus",
            style: .success
        ) {}

        // Bouton danger
        BoutonImageView(
            title: "Supprimer",
            systemImage: "trash",
            style: .danger
        ) {}
    }
    .padding()
}
