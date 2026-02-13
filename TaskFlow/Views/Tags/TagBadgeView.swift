//
//  TagCardView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagBadgeView: View {

    let tag: TagResponse
    var onDelete: (() -> Void)? = nil

    var body: some View {
        Text(tag.tagName)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Color(hex: tag.couleur)
                    .opacity(0.18)
            )
            .foregroundColor(Color(hex: tag.couleur))
            .clipShape(Capsule())

            // Long press menu
            .contextMenu {
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
