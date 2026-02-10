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

    @StateObject private var session = SessionViewModel()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isAuthenticated {
                    MainView()
                } else {
                    switch appState.flow {
                    case .welcome:
                        WelcomeView()
                    case .loginHome:
                        ConnexionView()
                    case .loginForm:
                        LoginView(sessionVM: session)
                    case .main:
                        EmptyView()
                    }
                }
            }
            .environmentObject(session)
            .environmentObject(appState)
        }
    }
}


