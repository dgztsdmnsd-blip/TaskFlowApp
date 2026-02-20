//
//  TagRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Ligne d’affichage d’un tag.
//  Utilisée dans les List / Picker.
//

import SwiftUI

struct TagRowView: View {

    // Tag affiché dans la ligne
    let tag: TagResponse

    var body: some View {
        HStack {

            // Indicateur couleur
            Circle()
                .fill(Color(hex: tag.couleur))
                .frame(width: 14, height: 14)

            // Nom du tag
            Text(tag.tagName)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
