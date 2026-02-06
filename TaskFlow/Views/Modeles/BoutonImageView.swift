//
//  BoutonImageView.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/02/2026.
//

import SwiftUI

import SwiftUI

struct BoutonImageView: View {

    enum Style {
        case primary
        case secondary
        case success
        case danger

        var gradient: LinearGradient {
            switch self {
            case .primary:
                return LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.55, blue: 0.85),
                        Color(red: 0.25, green: 0.45, blue: 0.75)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
            case .secondary:
                return LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.82, blue: 0.95),
                        Color(red: 0.58, green: 0.74, blue: 0.90)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

            case .success:
                return LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.80, blue: 0.65),
                        Color(red: 0.40, green: 0.70, blue: 0.55)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

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

    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(style.gradient)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 6,
                    y: 3
                )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    VStack(spacing: 16) {
        BoutonImageView(
            title: "Action standard",
            systemImage: "arrow.right",
            style: .primary
        ) {}

        BoutonImageView(
            title: "Créer le projet",
            systemImage: "folder.badge.plus",
            style: .success
        ) {}

        BoutonImageView(
            title: "Supprimer",
            systemImage: "trash",
            style: .danger
        ) {}
    }
    .padding()
}
