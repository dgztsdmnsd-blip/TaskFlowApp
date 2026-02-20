//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Point d’entrée principal de l’application.
//  Initialise les états globaux et
//  contrôle la navigation racine.
//

import SwiftUI

@main
struct TaskFlowApp: App {

    // StateObjects
    // Objets globaux conservés pendant toute la vie de l’app
    @StateObject private var session = SessionViewModel()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {


            // Choix de l’écran affiché au lancement
            Group {
                if session.isAuthenticated {

                    // Utilisateur connecté
                    MainView()

                } else {

                    // Utilisateur non connecté → navigation par flow
                    switch appState.flow {

                    case .welcome:
                        WelcomeView()

                    case .loginHome:
                        ConnexionView()

                    case .loginForm:
                        LoginView(sessionVM: session)

                    case .main:
                        EmptyView() // Sécurité
                    }
                }
            }

            // Environment Objects
            // Injection des états globaux dans toute l’app
            .environmentObject(session)
            .environmentObject(appState)
        }
    }
}
