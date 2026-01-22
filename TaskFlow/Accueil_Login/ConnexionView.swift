//
//  ConnexionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct ConnexionView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Couleur de fond
                BackgroundView()
                
                VStack(spacing: 20) {
                    
                    // Titre
                    TitreView(couleur: .white, texte:"Bienvenue sur TaskFlow")
                    
                    // Sous titre
                    SousTitreView(couleur: .white, texte:"L'application de gestion de vos projets en mode Agile")
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Bouton Connexion
                        NavigationLink {
                            LoginView()
                        } label: {
                            BoutonView(title: "Connexion")
                        }
                        .buttonStyle(.plain)

                        // Bouton Inscription
                        NavigationLink {
                            // SignupView()
                        } label: {
                            BoutonView(title: "Inscription")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(32)
            }
        }
    }
}

#Preview {
    ConnexionView()
}
