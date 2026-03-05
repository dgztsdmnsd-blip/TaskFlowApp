//
//  ProjectsView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  Écran affichant la liste des projets de l’utilisateur.
//  Gère les états : chargement, erreur, liste vide.
//  Permet la navigation vers le détail d’un projet.
//
//

import SwiftUI

// Vue affichant la liste des projets
struct ProjectsView: View {

    // Session utilisateur (utilisateur connecté)
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // ViewModel contenant les projets
    @StateObject private var vm: ProjectListViewModel

    // Projet sélectionné (navigation vers détail)
    @State private var selectedProject: ProjectResponse?

    // Initialisation standard (production)
    init() {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // Initialisation avec injection VM (preview / tests)
    init(vm: ProjectListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {

            // Fond personnalisé écran Projets
            BackgroundView(ecran: .projets)

            VStack {

                // Affichage pendant le chargement
                if vm.isLoading {
                    ProgressView()

                // Affichage en cas d’erreur
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                // Affichage si aucun projet
                } else if vm.projects.isEmpty {
                    Text("Aucun projet trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                // Liste des projets
                } else {
                    List(vm.projects) { project in

                        // Sélection du projet → navigation
                        Button {
                            selectedProject = project
                        } label: {

                            // Ligne projet
                            ProjectsRowView(
                                project: project,
                                isOwner: project.owner.id == sessionVM.currentUser?.id
                            )
                        }
                        .accessibilityIdentifier("project.row.\(project.id)")
                    }
                    // Cache le fond gris natif
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("projects.list")
                }
            }
        }
        // Navigation vers l’écran détail projet
        .navigationDestination(item: $selectedProject) { project in
            ProjectDetailView(
                vm: ProjectDetailViewModel(project: project)
            )
        }
        // Debug cycle de vie
        .logLifecycle("ProjectsView")
        // Chargement initial des projets
        .task {
            await vm.fetchProjects()
        }
        // Rafraîchissement via notification
        .onReceive(
            NotificationCenter.default.publisher(for: .projectListShouldRefresh)
        ) { _ in
            Task { await vm.fetchProjects() }
        }
    }
}
