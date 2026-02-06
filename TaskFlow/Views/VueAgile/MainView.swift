//
//  MainView.swift
//  TaskFlow
//
//  Vue principale après authentification.
//  Elle s’appuie uniquement sur SessionViewModel
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var session: SessionViewModel

    @State private var showProfile = false
    @State private var showProject = false

    var body: some View {
        Group {
            if let user = session.currentUser {

                TabView {

                    // --------------------
                    // À venir
                    // --------------------
                    NavigationStack {
                        TodoView()
                            .navigationTitle("À venir")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("À venir", systemImage: "calendar")
                    }

                    // --------------------
                    // En cours
                    // --------------------
                    NavigationStack {
                        InProgressView()
                            .navigationTitle("En cours")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("En cours", systemImage: "clock")
                    }

                    // --------------------
                    // Terminées
                    // --------------------
                    NavigationStack {
                        CompletedView()
                            .navigationTitle("Terminées")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("Terminées", systemImage: "checkmark.circle.fill")
                    }

                    // --------------------
                    // Admin
                    // --------------------
                    if user.profil == "MGR" {

                        NavigationStack {
                            UsersListView(currentUser: user)
                                .navigationTitle("Utilisateurs")
                                .toolbar { profileButton }
                        }
                        .tabItem {
                            Label("Utilisateurs", systemImage: "person.3.fill")
                        }

                        NavigationStack {
                            ProjectsView()
                                .navigationTitle("Projets")
                                .toolbar { projectButton }
                        }
                        .tabItem {
                            Label("Projets", systemImage: "folder.fill")
                        }
                    }
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                .sheet(isPresented: $showProject) {
                    ProjectCreationView(
                        viewModel: ProjectFormViewModel(mode: .create),
                        onCreated: {
                            NotificationCenter.default.post(
                                name: .projectListShouldRefresh,
                                object: nil
                            )
                        }
                    )
                    .presentationDetents([.medium, .large])
                }

            } else {
                ProgressView("Initialisation…")
            }
        }
    }

    // --------------------
    // Toolbar buttons
    // --------------------
    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
            }
        }
    }

    private var projectButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProject = true
            } label: {
                Image(systemName: "folder.badge.plus")
            }
        }
    }
}

#Preview {
    let session = SessionViewModel()
    session.currentUser = .preview
    session.isAuthenticated = true

    return MainView()
        .environmentObject(session)
}
