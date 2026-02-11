//
//  CardStyleView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//

import SwiftUI

struct CardStyleView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

extension View {
    func cardStyleView() -> some View {
        modifier(CardStyleView())
    }
}
