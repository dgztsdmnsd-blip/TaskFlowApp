//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Point d’entrée principal de l’application.
//  Il initialise l’état global (AppState)
//  et gère la navigation racine selon le flow courant.
//

import SwiftUI

@main
struct TaskFlowApp: App {

    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Navigation racine contrôlée par appState.flow.
                switch appState.flow {
                case .welcome:
                    // Écran d’accueil
                    WelcomeView()
                        .transition(.opacity)

                case .login:
                    // Écran de connexion (email + Face ID)
                    ConnexionView()
                        .transition(.move(edge: .trailing))

                case .main:
                    // Contenu principal de l’app (après authentification)
                    MainView()
                        .transition(.opacity)
                }
            }
            // Animation appliquée à chaque changement de flow
            .animation(.easeInOut(duration: 0.4), value: appState.flow)
        }
        // Injection de l’état global dans toute la hiérarchie de vues
        // via EnvironmentObject.
        // Toutes les vues peuvent lire/modifier appState.flow.
        .environmentObject(appState)
    }
}




