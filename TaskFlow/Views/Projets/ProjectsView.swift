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

    // Session utilisateur (utilisateur courant)
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // ViewModel contenant la liste des projets
    @StateObject private var vm: ProjectListViewModel

    // Initialisation en production
    init() {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // Initialisation pour preview / test
    init(vm: ProjectListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
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
                    
                    // Navigation vers le détail
                    NavigationLink {
                        ProjectDetailView(
                            vm: ProjectDetailViewModel(project: project)
                        )
                    } label: {
                        
                        // Ligne projet
                        ProjectsRowView(
                            project: project,
                            isOwner: project.owner.id == sessionVM.currentUser?.id
                        )
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        // Fond personnalisé
        .background(
            BackgroundView(ecran: .projets)
        )
        // Log cycle de vie (debug)
        .logLifecycle("ProjectsView")
        // Chargement initial
        .task {
            // Évite les appels réseau en preview
            await vm.fetchProjects()
        }
        // Rafraîchissement via notification
        .onReceive(
            NotificationCenter.default.publisher(
                for: .projectListShouldRefresh
            )
        ) { _ in
            Task { await vm.fetchProjects() }
        }
    }
}

