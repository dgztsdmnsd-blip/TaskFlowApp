//
//  BackgroundView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Vue responsable de l’affichage du fond dégradé
//  selon l’écran et le thème (Light / Dark).
//

import SwiftUI

struct BackgroundView: View {

    // Thème système actif
    @Environment(\.colorScheme) private var scheme

    // Écrans supportés
    enum Ecran {
        case general
        case stories
        case projets
        case users
        case tasks
        case tags
    }

    // Écran courant
    let ecran: Ecran

    // -------------------------
    // Couleurs LIGHT (pastel)
    // -------------------------
    private let colgendeb_L = Color(red: 0.75, green: 0.65, blue: 0.95)
    private let colgenfin_L = Color(red: 0.55, green: 0.80, blue: 0.95)

    private let colprojdeb_L = Color(red: 0.88, green: 0.96, blue: 0.91)
    private let colprojfin_L = Color(red: 0.78, green: 0.92, blue: 0.84)

    private let colstoriesdeb_L = Color(red: 1.00, green: 0.95, blue: 0.90)
    private let colstoriesfin_L = Color(red: 1.00, green: 0.82, blue: 0.72)

    private let coluserdeb_L = Color(red: 0.85, green: 0.92, blue: 0.98)
    private let coluserfin_L = Color(red: 0.72, green: 0.85, blue: 0.95)

    private let coltaskdeb_L = Color(red: 0.86, green: 0.96, blue: 0.97)
    private let coltaskfin_L = Color(red: 0.70, green: 0.90, blue: 0.93)

    private let coltagdeb_L = Color(red: 0.99, green: 0.92, blue: 0.94)
    private let coltagfin_L = Color(red: 0.96, green: 0.78, blue: 0.82)

    // -------------------------
    // Couleurs DARK (plus profondes)
    // -------------------------
    private let colgendeb_D = Color(red: 0.32, green: 0.28, blue: 0.55)
    private let colgenfin_D = Color(red: 0.22, green: 0.40, blue: 0.60)

    private let colprojdeb_D = Color(red: 0.16, green: 0.30, blue: 0.22)
    private let colprojfin_D = Color(red: 0.12, green: 0.22, blue: 0.16)

    private let colstoriesdeb_D = Color(red: 0.45, green: 0.30, blue: 0.18)
    private let colstoriesfin_D = Color(red: 0.60, green: 0.38, blue: 0.22)

    private let coluserdeb_D = Color(red: 0.18, green: 0.26, blue: 0.40)
    private let coluserfin_D = Color(red: 0.12, green: 0.18, blue: 0.30)

    private let coltaskdeb_D = Color(red: 0.12, green: 0.30, blue: 0.32)
    private let coltaskfin_D = Color(red: 0.10, green: 0.22, blue: 0.24)

    private let coltagdeb_D = Color(red: 0.35, green: 0.18, blue: 0.26)
    private let coltagfin_D = Color(red: 0.25, green: 0.12, blue: 0.18)

    // Indique si Dark Mode actif
    private var isDark: Bool { scheme == .dark }

    // Couleur de départ du gradient
    private var coldeb: Color {
        switch ecran {
        case .general: return isDark ? colgendeb_D : colgendeb_L
        case .stories: return isDark ? colstoriesdeb_D : colstoriesdeb_L
        case .projets: return isDark ? colprojdeb_D : colprojdeb_L
        case .users:   return isDark ? coluserdeb_D : coluserdeb_L
        case .tasks:   return isDark ? coltaskdeb_D : coltaskdeb_L
        case .tags:    return isDark ? coltagdeb_D : coltagdeb_L
        }
    }

    // Couleur de fin du gradient
    private var colfin: Color {
        switch ecran {
        case .general: return isDark ? colgenfin_D : colgenfin_L
        case .stories: return isDark ? colstoriesfin_D : colstoriesfin_L
        case .projets: return isDark ? colprojfin_D : colprojfin_L
        case .users:   return isDark ? coluserfin_D : coluserfin_L
        case .tasks:   return isDark ? coltaskfin_D : coltaskfin_L
        case .tags:    return isDark ? coltagfin_D : coltagfin_L
        }
    }

    var body: some View {

        // Gradient vertical plein écran
        LinearGradient(
            colors: [coldeb, colfin],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}


extension BackgroundView {

    // Gradient tâches adaptatif
    static func tasksGradient(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [
                    Color(red: 0.12, green: 0.30, blue: 0.32),
                    Color(red: 0.10, green: 0.22, blue: 0.24)
                  ]
                : [
                    Color(red: 0.86, green: 0.96, blue: 0.97),
                    Color(red: 0.70, green: 0.90, blue: 0.93)
                  ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Gradient user stories adaptatif
    static func storyGradient(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [
                    Color(red: 0.45, green: 0.30, blue: 0.18),
                    Color(red: 0.60, green: 0.38, blue: 0.22)
                  ]
                : [
                    Color(red: 1.00, green: 0.95, blue: 0.90),
                    Color(red: 1.00, green: 0.82, blue: 0.72)
                  ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
