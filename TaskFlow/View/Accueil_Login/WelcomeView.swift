//
//  WelcomeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            BackgroundView(ecran: .general)

            Image("Accueil")
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(spacing: 20) {
                TitreView(couleur: .black, texte:"Bienvenue sur TaskFlow")
                SousTitreView(couleur: .black, texte:"L'application de gestion de vos projets en mode Agile")
                Spacer()
            }
            .padding(32)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                appState.flow = .login
            }
        }
    }
}


#Preview {
    WelcomeView()
}
