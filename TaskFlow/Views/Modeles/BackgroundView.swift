//
//  BackgroundView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Vue responsable de l’affichage du fond dégradé
//  en fonction de l’écran courant.
//

import SwiftUI

struct BackgroundView: View {

    enum Ecran {
        case general
        case stories
        case projets
        case users
        case tasks
        case tags
    }

    let ecran: Ecran

    // Général: Violet
    private let colgendeb = Color(red: 0.75, green: 0.65, blue: 0.95)
    private let colgenfin = Color(red: 0.55, green: 0.80, blue: 0.95)

    // Projets: Vert clair
    private let colprojdeb = Color(red: 0.88, green: 0.96, blue: 0.91)
    private let colprojfin = Color(red: 0.78, green: 0.92, blue: 0.84)

    // Stories: Orange
    private let colstoriesdeb = Color(red: 1.00, green: 0.95, blue: 0.90)
    private let colstoriesfin = Color(red: 1.00, green: 0.82, blue: 0.72)
    
    // User: Bleu clair
    private let coluserdeb = Color(red: 0.85, green: 0.92, blue: 0.98)
    private let coluserfin = Color(red: 0.72, green: 0.85, blue: 0.95)
    
    // Tasks: Turquoise clair
    private let coltaskdeb = Color(red: 0.86, green: 0.96, blue: 0.97)
    private let coltaskfin = Color(red: 0.70, green: 0.90, blue: 0.93)
    
    // Tags: Rose poudré
    private let coltagdeb = Color(red: 0.99, green: 0.92, blue: 0.94)
    private let coltagfin = Color(red: 0.96, green: 0.78, blue: 0.82)



    private var coldeb: Color {
        switch ecran {
        case .stories: return colstoriesdeb
        case .general: return colgendeb
        case .projets: return colprojdeb
        case .users:   return coluserdeb
        case .tasks:   return coltaskdeb
        case .tags:    return coltagdeb
        }
    }

    private var colfin: Color {
        switch ecran {
        case .stories: return colstoriesfin
        case .general:   return colgenfin
        case .projets:   return colprojfin
        case .users:     return coluserfin
        case .tasks:     return coltaskfin
        case .tags:      return coltagfin
        }
    }

    var body: some View {
        LinearGradient(
            colors: [coldeb, colfin],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension BackgroundView {

    static let tasksGradient = LinearGradient(
        colors: [
            Color(red: 0.86, green: 0.96, blue: 0.97),
            Color(red: 0.70, green: 0.90, blue: 0.93)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let StoryGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.95, blue: 0.90),
            Color(red: 1.00, green: 0.82, blue: 0.72)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

#Preview {
    BackgroundView(ecran: .general)
}
