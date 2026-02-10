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
        case terminees
        case enCours
        case aVenir
        case projets
        case users
    }

    let ecran: Ecran

    // Général: Violet
    private let colgendeb = Color(red: 0.75, green: 0.65, blue: 0.95)
    private let colgenfin = Color(red: 0.55, green: 0.80, blue: 0.95)

    // Terminées: Vert
    private let colcompdeb = Color(red: 0.60, green: 0.85, blue: 0.70)
    private let colcompfin = Color(red: 0.45, green: 0.75, blue: 0.60)
    
    // Projets: Vert clair
    private let colprojdeb = Color(red: 0.88, green: 0.96, blue: 0.91)
    private let colprojfin = Color(red: 0.78, green: 0.92, blue: 0.84)

    // En cours: Bleu
    private let colencdeb = Color(red: 0.55, green: 0.75, blue: 0.95)
    private let colencfin = Color(red: 0.35, green: 0.60, blue: 0.90)

    // À venir: Lavande
    private let coltododeb = Color(red: 0.75, green: 0.70, blue: 0.95)
    private let coltodofin = Color(red: 0.60, green: 0.55, blue: 0.90)
    
    // User: Bleu clair
    private let coluserdeb = Color(red: 0.85, green: 0.92, blue: 0.98)
    private let coluserfin = Color(red: 0.72, green: 0.85, blue: 0.95)


    private var coldeb: Color {
        switch ecran {
        case .terminees: return colcompdeb
        case .enCours:   return colencdeb
        case .aVenir:    return coltododeb
        case .general:   return colgendeb
        case .projets:   return colprojdeb
        case .users:     return coluserdeb
        }
    }

    private var colfin: Color {
        switch ecran {
        case .terminees: return colcompfin
        case .enCours:   return colencfin
        case .aVenir:    return coltodofin
        case .general:   return colgenfin
        case .projets:   return colprojfin
        case .users:     return coluserfin
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

#Preview {
    BackgroundView(ecran: .general)
}
