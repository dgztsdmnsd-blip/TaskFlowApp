//
//  WelcomeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct WelcomeView: View {

    @State private var navigate = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fond
                BackgroundView()
                
                // Image de fond
                Image("Accueil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                VStack(spacing: 20) {
                    // Titre
                    TitreView(couleur: .black, texte:"Bienvenue sur TaskFlow")

                    // Sous titre
                    SousTitreView(couleur: .black, texte:"L'application de gestion de vos projets en mode Agile")

                    Spacer()
                }
                .padding(32)
            }
            .onAppear {
                // Passage à l'écran de connexion au bout de 2,5 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigate = true
                }
            }
            .navigationDestination(isPresented: $navigate) {
                ConnexionView()
            }
        }
    }
}


#Preview {
    WelcomeView()
}
