//
//  AppNavigationTitle.swift
//  TaskFlow
//
//  Created by luc banchetti on 19/02/2026.
//
//  Modificateur appliquant un titre de navigation personnalisé
//  utilisé pour homogénéiser les NavigationStack.
//

import SwiftUI

struct AppNavigationTitle: ViewModifier {

    // Texte affiché dans la barre de navigation
    let title: String
    
    // Schéma de couleur actif (Light / Dark)
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
        
            // Affichage du titre en mode inline
            .navigationBarTitleDisplayMode(.inline)
            
            // Injection du titre personnalisé
            .toolbar {
                ToolbarItem(placement: .principal) {
                    
                    HStack {
                        
                        // Titre principal
                        Text(title)
                            .font(.system(size: 24, weight: .bold))
                            
                            // Adaptation automatique Light/Dark
                            .adaptiveTextColor()

                        // Pousse le titre à gauche
                        Spacer()
                    }
                    // Étire le contenu sur toute la largeur
                    .frame(maxWidth: .infinity)
                }
            }
    }
}
