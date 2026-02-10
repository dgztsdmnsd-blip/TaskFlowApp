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

import SwiftUI

struct ConnexionView: View {

    @EnvironmentObject var sessionVM: SessionViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView(ecran: .general)

                VStack(spacing: 20) {

                    TitreView(
                        couleur: .white,
                        texte: "Bienvenue sur TaskFlow"
                    )

                    SousTitreView(
                        couleur: .white,
                        texte: "L'application de gestion de vos projets en mode Agile"
                    )

                    Spacer()

                    VStack(spacing: 16) {

                        NavigationLink {
                            LoginView(sessionVM: sessionVM)
                        } label: {
                            BoutonView(title: "Connexion")
                        }
                        .buttonStyle(.plain)

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
        }
    }
}


#Preview {
    ConnexionView()
}
