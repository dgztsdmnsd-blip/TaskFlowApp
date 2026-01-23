//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

@main
struct TaskFlowApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appState.flow {
                case .welcome:
                    WelcomeView()
                        .transition(.opacity)

                case .login:
                    LoginView()
                        .transition(.move(edge: .trailing))

                case .main:
                    MainView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.flow)
        }
        .environmentObject(appState)
    }
}

