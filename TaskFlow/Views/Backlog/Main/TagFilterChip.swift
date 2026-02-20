//
//  TagFilterChip.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Chip UI utilisé pour filtrer par tag.
//  Affiche un état sélectionné / non sélectionné.
//

import SwiftUI

struct TagFilterChip: View {


    // Texte affiché dans la chip
    var title: String

    // Couleur principale du tag
    var color: Color = .gray

    // Indique si la chip est sélectionnée
    var isSelected: Bool

    // Action déclenchée au tap
    var action: () -> Void

    var body: some View {

        // Button
        Button(action: action) {

            Text(title)
                .font(.caption.bold())

                // Espacement interne
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                // Background adaptatif
                .background(
                    isSelected
                        ? color
                        : color.opacity(0.2)
                )

                // Couleur du texte
                .foregroundColor(
                    isSelected ? .white : color
                )

                // Forme capsule
                .clipShape(Capsule())
        }
    }
}
