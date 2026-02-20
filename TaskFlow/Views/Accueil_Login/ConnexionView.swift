//
//  ConnexionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Écran intermédiaire entre Welcome et Login.
//  Sert de point d’entrée pour :
//  - Connexion
//  - Inscription
//

import SwiftUI

struct ConnexionView: View {

    // ViewModel de session injecté globalement
    @EnvironmentObject var sessionVM: SessionViewModel

    var body: some View {

        // Navigation Container
        NavigationStack {

            ZStack {

                // Background
                BackgroundView(ecran: .general)

                VStack(spacing: 20) {

                    // Header
                    TitreView(
                        texte: "Bienvenue sur TaskFlow"
                    )

                    SousTitreView(
                        texte: "L'application de gestion de vos projets en mode Agile"
                    )

                    Spacer()

                    // Actions
                    VStack(spacing: 16) {

                        // Bouton Connexion
                        NavigationLink {
                            LoginView(sessionVM: sessionVM)
                        } label: {
                            BoutonView(title: "Connexion")
                        }
                        .buttonStyle(.plain)

                        // Bouton Inscription
                        NavigationLink {
                            RegisterView(mode: .create)
                        } label: {
                            BoutonView(title: "Inscription")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(32)
            }

            // Debug Lifecycle
            .logLifecycle("ConnexionView")
        }
    }
}

#Preview {
    ConnexionView()
}
