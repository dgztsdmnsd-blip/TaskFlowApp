//
//  TagCardView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Badge visuel d’un tag (version standard).
//  Utilisé dans :
//  - Filtres
//  - Formulaires
//  - Détails User Story
//

import SwiftUI

struct TagBadgeView: View {

    // Tag affiché
    let tag: TagResponse

    // Action optionnelle de suppression
    var onDelete: (() -> Void)? = nil

    var body: some View {

        // Badge
        Text(tag.tagName)
            .font(.caption.bold())
            // Espacement interne
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            // Background léger teinté
            .background(
                Color(hex: tag.couleur)
                    .opacity(0.18)
            )
            // Couleur principale
            .foregroundColor(Color(hex: tag.couleur))
            // Forme capsule
            .clipShape(Capsule())
            // Context Menu (long press)
            .contextMenu {

                // Suppression si action fournie
                if let onDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }
    }
}
