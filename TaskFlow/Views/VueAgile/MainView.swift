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
                    // Backlog
                    // --------------------
                    NavigationStack {
                        BacklogView()
                            .navigationTitle("Backlog")
                            .toolbar { profileButton }
                            .sheet(isPresented: $showProfile) {
                                ProfileView()
                            }
                    }
                    .tabItem {
                        Label("Backlog", systemImage: "checkmark.circle.fill")
                    }

                    // --------------------
                    // Admin
                    // --------------------
                    if user.profil == "MGR" {

                        NavigationStack {
                            UsersListView(currentUser: user)
                                .navigationTitle("Utilisateurs")
                                .toolbar { profileButton }
                                .sheet(isPresented: $showProfile) {
                                    ProfileView()
                                }
                        }
                        .tabItem {
                            Label("Utilisateurs", systemImage: "person.3.fill")
                        }

                        NavigationStack {
                            ProjectsView()
                                .navigationTitle("Projets")
                                .toolbar { projectButton }
                                .fullScreenCover(isPresented: $showProject) {
                                    ProjectCreationView(
                                        viewModel: ProjectFormViewModel(mode: .create),
                                        onCreated: {
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
                        }
                    }
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
