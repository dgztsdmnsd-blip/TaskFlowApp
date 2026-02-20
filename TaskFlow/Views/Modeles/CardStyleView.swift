//
//  CardStyleView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//
//  Modificateur appliquant un style "carte"
//  homogène dans toute l’application.
//

import SwiftUI

struct CardStyleView: ViewModifier {

    func body(content: Content) -> some View {
        content

            // Espacement interne
            .padding()
            
            // Background carte
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            
            // Bordure subtile
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.primary.opacity(0.05),
                        lineWidth: 1
                    )
            )
            
            // Ombre légère
            .shadow(
                color: .black.opacity(0.04),
                radius: 8,
                y: 2
            )
    }
}

// Extension pratique pour appliquer le style
extension View {

    func cardStyleView() -> some View {
        modifier(CardStyleView())
    }
}
