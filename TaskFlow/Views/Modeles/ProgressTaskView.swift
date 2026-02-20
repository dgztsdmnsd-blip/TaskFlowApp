//
//  ProgressTaskView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//
//  Composant affichant la progression d’une tâche
//  avec une barre et un pourcentage.
//

import SwiftUI

struct ProgressTaskView: View {

    // Valeur de progression (0.0 → 1.0)
    var progression: Double
    
    // Couleur dynamique selon l’avancement
    private var progressColor: Color {
        switch progression {
        // Faible progression
        case 0..<0.3:
            return .red
        // Progression intermédiaire
        case 0.3..<0.7:
            return .orange
        // Progression élevée
        default:
            return .green
        }
    }
    
    var body: some View {
        
        // Barre de progression
        ProgressView(value: progression)
            .tint(progressColor)
        
        // Texte du pourcentage
        Text("\(Int(progression * 100)) % terminé")
            .font(.caption)
            .adaptiveTextColor()
    }
}

#Preview {
    ProgressTaskView(progression: 0.5)
}
