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

struct MainView_PreviewWrapper: View {

    @StateObject private var profileVM = ProfileViewModel.preview
    var body: some View {
        MainViewWithInjectedVM(profileVM: profileVM)
    }
}


struct MainViewWithInjectedVM: View {

    @ObservedObject var profileVM: ProfileViewModel
    @State private var showProfile = false
    @State private var showProject = false

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
                        TodoView()
                            .navigationTitle("À venir")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("À venir", systemImage: "calendar")
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
                        CompletedView()
                            .navigationTitle("Complétées")
                            .toolbar { profileButton }
                    }
                    .tabItem {
                        Label("Terminées", systemImage: "checkmark.circle.fill")
                    }

                    if profileVM.isAdmin {
                        NavigationStack {
                            UsersListView(currentUser: profile)
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
                    ProfileView(viewModel: profileVM)
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

struct MainView: View {

    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        MainViewWithInjectedVM(profileVM: profileVM)
    }
}


#Preview {
    MainView_PreviewWrapper()
}
