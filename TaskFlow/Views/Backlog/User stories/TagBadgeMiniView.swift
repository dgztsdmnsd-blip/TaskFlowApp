//
//  TagBadgeMiniView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagBadgeMiniView: View {

    let tag: TagResponse
    var onDelete: (() -> Void)? = nil

    var body: some View {
        Text(tag.tagName)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Color(hex: tag.couleur).opacity(0.18)
            )
            .foregroundColor(Color(hex: tag.couleur))
            .clipShape(Capsule())

            // Menu contextuel (long press)
            .contextMenu {
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
    }
}
