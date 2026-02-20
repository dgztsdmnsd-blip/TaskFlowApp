//
//  FlowLayout.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Layout adaptatif type "flow".
//  Permet d’afficher dynamiquement des éléments
//  sur plusieurs lignes selon l’espace disponible.
//

import SwiftUI

struct FlowLayout<Content: View>: View {

    // Espacement horizontal et vertical entre éléments
    var spacing: CGFloat = 8

    // Contenu injecté (chips, tags, badges…)
    let content: () -> Content

    // Initialisation
    init(
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    // Body
    var body: some View {

        // LazyVGrid avec colonnes adaptatives
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 80),
                    spacing: spacing
                )
            ],
            spacing: spacing
        ) {
            content()
        }
    }
}
