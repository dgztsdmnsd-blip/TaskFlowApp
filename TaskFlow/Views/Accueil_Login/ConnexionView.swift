//
//  ConnexionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Écran intermédiaire entre le Welcome et le Login.
//  Il sert de point d’entrée pour :
//  - la connexion
//  - (plus tard) l’inscription
//

import SwiftUI

struct ConnexionView: View {

    var body: some View {
        // la navigation vers LoginView
        NavigationStack {
            ZStack {

                // Fond général de l’application
                BackgroundView(ecran: .general)

                VStack(spacing: 20) {

                    // Titre principal
                    TitreView(
                        couleur: .white,
                        texte: "Bienvenue sur TaskFlow"
                    )

                    // Sous-titre descriptif
                    SousTitreView(
                        couleur: .white,
                        texte: "L'application de gestion de vos projets en mode Agile"
                    )

                    Spacer()

                    VStack(spacing: 16) {

                        // Bouton Connexion
                        // Navigation vers l’écran de login
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
