//
//  WelcomeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Écran d’accueil (splash screen) affiché au lancement
//  de l’application avant la navigation vers l’écran de connexion.
//

import SwiftUI

struct WelcomeView: View {

    // Permet de changer le flow (welcome → login)
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {

            // Fond général de l’application
            BackgroundView(ecran: .general)

            // Image d’accueil
            Image("Accueil")
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(spacing: 20) {

                // Titre principal
                TitreView(
                    couleur: .black,
                    texte: "Bienvenue sur TaskFlow"
                )

                // Sous-titre descriptif
                SousTitreView(
                    couleur: .black,
                    texte: "L'application de gestion de vos projets en mode Agile"
                )

                // Pousse le contenu vers le haut
                Spacer()
            }
            .padding(32)
        }
        /// Transition automatique
        .onAppear {
            // Après 2,5 secondes, on quitte l’écran d’accueil
            // pour afficher l’écran de connexion.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                appState.flow = .login
            }
        }
    }
}


#Preview {
    WelcomeView()
}
