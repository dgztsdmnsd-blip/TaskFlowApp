//
//  ProjectUsersView.swift
//  TaskFlow
//
//  Created by luc banchetti on 04/02/2026.
//
//  Écran affichant les membres d’un projet.
//  Permet de consulter la liste, supprimer un membre,
//  et ajouter de nouveaux utilisateurs.
//  Gère les états : chargement, erreur, liste vide.
//

import SwiftUI

// Vue affichant les membres d’un projet
struct ProjectUsersView: View {

    // ViewModel contenant les membres du projet
    @StateObject private var vm: ProjectUsersViewModel
    
    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss

    // Contrôle l’affichage de la sheet d’ajout
    @State private var showAddMember = false

    // Initialisation en production
    init(project: ProjectResponse) {
        _vm = StateObject(
            wrappedValue: ProjectUsersViewModel(projectId: project.id)
        )
    }

    // Initialisation pour preview / test
    init(vm: ProjectUsersViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            
            // Fond personnalisé
            BackgroundView(ecran: .projets)

            VStack(spacing: 12) {

                // Chargement
                if vm.isLoading {
                    ProgressView()

                // Erreur
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                // Aucun membre
                } else if vm.members.isEmpty {
                    Text("Aucun membre trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                // Liste des membres
                } else {
                    List {
                        ForEach(vm.members) { member in
                            
                            let isOwner = (vm.ownerId == member.id)

                            // Ligne membre
                            ProfileRowView(user: member, isOwner: isOwner)
                            
                                // Swipe → Supprimer (si non owner)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if !isOwner {
                                        Button(role: .destructive) {
                                            Task {
                                                await vm.removeMember(userId: member.id)
                                                
                                                // Notification detail projet
                                                if vm.errorMessage == nil {
                                                    NotificationCenter.default.post(
                                                        name: .projectDidChange,
                                                        object: vm.projectId
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                // Bouton ajouter membre
                BoutonImageView(
                    title:  "Ajouter un membre",
                    systemImage:  "person.badge.plus",
                    style: .primary
                ) {
                    showAddMember = true
                }
            }
            .padding(.top)
        }
        .appNavigationTitle("Membres du projet")
        .logLifecycle("ProjectUsersView")
        // Chargement initial des membres
        .task {
            await vm.fetchMembers()
        }
        // Sheet sélection utilisateur
        .sheet(isPresented: $showAddMember) {
            NavigationStack {
                ProjectUserSelectionView(
                    excludedUserIds: Set(vm.members.map(\.id)),
                    onAddMember: { userId in
                        Task {
                            await vm.addMember(userId: userId)
                            
                            // Notification detail projet
                            if vm.errorMessage == nil {
                                NotificationCenter.default.post(
                                    name: .projectDidChange,
                                    object: vm.projectId
                                )
                            }
                            
                            showAddMember = false
                        }
                    }
                )
            }
        }
        // Bouton fermer
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.app.fill")
                }
                .accessibilityLabel("Fermer")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectUsersView(
            vm: ProjectUsersViewModel(projectId: 1)
        )
    }
}
