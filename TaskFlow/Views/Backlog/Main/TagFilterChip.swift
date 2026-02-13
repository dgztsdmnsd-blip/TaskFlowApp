//
//  TagFilterChip.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagFilterChip: View {

    var title: String
    var color: Color = .gray
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    (isSelected ? color : color.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : color)
                .clipShape(Capsule())
        }
    }
}
