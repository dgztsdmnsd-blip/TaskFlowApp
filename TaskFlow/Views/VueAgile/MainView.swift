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

    @State private var showProfile = false
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        Group {
            if profileVM.isLoading {
                ProgressView("Chargement du profil…")

            } else if let error = profileVM.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()

                    Button("Réessayer") {
                        Task { await profileVM.fetchProfile() }
                    }
                }

            } else if let profile = profileVM.profile {

                TabView {
                    NavigationStack {
                        CompletedView()
                            .navigationTitle("Complétées")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("Terminées", systemImage: "checkmark.circle.fill")
                    }

                    NavigationStack {
                        InProgressView()
                            .navigationTitle("En cours")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("En cours", systemImage: "clock")
                    }

                    NavigationStack {
                        TodoView()
                            .navigationTitle("À venir")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("À venir", systemImage: "calendar")
                    }

                    NavigationStack {
                        UsersListView(currentUser: profile)
                            .navigationTitle("Utilisateurs")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("Utilisateurs", systemImage: "person.3.fill")
                    }
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView(viewModel: profileVM)
                }

            } else {
                ProgressView("Initialisation…")
            }
        }
        .onAppear {
            if profileVM.profile == nil {
                Task {
                    await profileVM.fetchProfile()
                }
            }
        }
    }

    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
            }
        }
    }
}
