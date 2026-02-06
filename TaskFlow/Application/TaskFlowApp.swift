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
    @StateObject private var session = SessionViewModel()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appState.flow {
                case .welcome:
                    WelcomeView()

                case .loginHome:
                    ConnexionView()

                case .loginForm:
                    LoginView()

                case .main:
                    MainView()
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.flow)
            .task {
                await session.loadCurrentUser()
            }
            .onChange(of: session.isAuthenticated) { _, isAuth in
                appState.flow = isAuth ? .main : .loginHome
            }
            .environmentObject(appState)
            .environmentObject(session)
        }
    }
}

