//
//  MainView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Vue principale après authentification.
//  Affiche les onglets selon le profil utilisateur.
//

import SwiftUI

struct MainView: View {

    // Session utilisateur globale
    @EnvironmentObject private var session: SessionViewModel

    // State (UI)
    @State private var showProfile = false
    @State private var showProject = false
    
    // Reconnaitre le champ dans les tests UI
    var accessibilityId: String? = nil

    var body: some View {
        Group {

            // Vérifie que l’utilisateur est chargé
            if let user = session.currentUser {

                // Tab Navigation
                TabView {

                    // --------------------------------------------------
                    // Backlog Tab
                    // --------------------------------------------------
                    NavigationStack {
                        BacklogView()
                            .appNavigationTitle("Backlog")
                            .toolbar { profileButton }

                            // Profil utilisateur
                            .fullScreenCover(isPresented: $showProfile) {
                                NavigationStack {
                                    ProfileView()
                                }
                            }
                    }
                    .tabItem {
                        Label("Backlog", systemImage: "checkmark.circle.fill")
                            .accessibilityIdentifier("mainview.backlog")
                    }

                    // --------------------------------------------------
                    // Admin Tabs (Manager uniquement)
                    // --------------------------------------------------
                    if user.profil == "MGR" {

                        // Utilisateurs
                        NavigationStack {
                            UsersListView(currentUser: user)
                                .appNavigationTitle("Utilisateurs")
                                .toolbar { profileButton }

                                // Profil utilisateur
                                .sheet(isPresented: $showProfile) {
                                    ProfileView()
                                }
                        }
                        .tabItem {
                            Label("Utilisateurs", systemImage: "person.3.fill")
                                .accessibilityIdentifier("mainview.users")
                        }

                        // Projets
                        NavigationStack {
                            ProjectsView()
                                .appNavigationTitle("Projets")
                                .toolbar { projectButton }

                                // Création projet
                                .fullScreenCover(isPresented: $showProject) {
                                    ProjectCreationView(
                                        viewModel: ProjectFormViewModel(mode: .create),
                                        onCreated: {
                                            // Rafraîchit la liste projets
                                            NotificationCenter.default.post(
                                                name: .projectListShouldRefresh,
                                                object: nil
                                            )
                                        }
                                    )
                                }
                        }
                        .tabItem {
                            Label("Projets", systemImage: "folder.fill")
                                .accessibilityIdentifier("mainview.projects")
                        }
                    }
                }

            } else {

                //  Chargement session
                ProgressView("Initialisation…")
            }
        }

        // Debug Lifecycle
        .logLifecycle("MainView")
    }
    // Toolbar Buttons
    // Bouton Profil
    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
            }
            .accessibilityIdentifier("mainview.profile")
        }
    }
    // Bouton Création Projet
    private var projectButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProject = true
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .accessibilityIdentifier("project.create")
        }
    }
}
