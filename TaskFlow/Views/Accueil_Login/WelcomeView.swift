//
//  WelcomeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Écran d’accueil
//  Affiché au lancement avant la navigation.
//

import SwiftUI

struct WelcomeView: View {

    // Permet de piloter la navigation globale
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {

            // Background
            BackgroundView(ecran: .general)

            VStack(spacing: 20) {

                // Header
                TitreView(
                    texte: "TaskFlow"
                )

                // Illustration
                Image("Accueil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding(32)
        }

        // Debug Lifecycle
        .logLifecycle("WelcomeView")

        // Auto Navigation
        .onAppear {

            // Petit délai type splash screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                // Transition vers écran de connexion
                appState.flow = .loginHome
            }
        }
    }
}

#Preview {
    WelcomeView()
}
