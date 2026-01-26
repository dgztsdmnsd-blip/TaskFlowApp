//
//  MainView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Vue principale affichée après authentification.
//  Elle repose sur une TabView avec trois sections,
//  chacune embarquée dans sa propre NavigationStack.
//

import SwiftUI

struct MainView: View {

    // Affichage ou non la feuille de profil
    @State private var showProfile = false

    // ViewModel du profil partagé avec la feuille ProfileView.
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        TabView {

            /// Onglet "Complétées"
            NavigationStack {
                CompletedView()
                    .navigationTitle("Complétées")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("Terminées", systemImage: "checkmark.circle.fill")
            }

            /// Onglet "En cours"
            NavigationStack {
                InProgressView()
                    .navigationTitle("En cours")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("En cours", systemImage: "clock")
            }

            /// Onglet "À venir"
            NavigationStack {
                TodoView()
                    .navigationTitle("À venir")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("À venir", systemImage: "calendar")
            }
        }
        .tint(.indigo)

        // Présentation du profil utilisateur
        .sheet(isPresented: $showProfile) {
            ProfileView(viewModel: profileVM)
        }
    }

    /// Bouton Profil (Toolbar)
    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
            }
        }
    }
}
