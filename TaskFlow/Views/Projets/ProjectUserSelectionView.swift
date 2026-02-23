//
//  ProjectUserSelectionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.//
//  Écran permettant de sélectionner un utilisateur
//  à ajouter comme membre d’un projet.
//  Les utilisateurs déjà membres peuvent être exclus.
//  Gère les états : chargement, erreur, liste vide.
//

import SwiftUI

// Vue de sélection d’utilisateurs pour ajout au projet
struct ProjectUserSelectionView: View {

    // ViewModel contenant la liste des utilisateurs
    @StateObject private var vm: UsersListViewModel

    // IDs des utilisateurs à exclure (déjà membres)
    let excludedUserIds: Set<Int>
    
    // Callback lors de l’ajout d’un membre
    let onAddMember: (Int) -> Void

    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss

    // Initialisation pour preview / test
    init(
        vm: UsersListViewModel,
        excludedUserIds: Set<Int> = [],
        onAddMember: @escaping (Int) -> Void = { _ in }
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.excludedUserIds = excludedUserIds
        self.onAddMember = onAddMember
    }
    
    // Initialisation en production
    init(
        excludedUserIds: Set<Int>,
        onAddMember: @escaping (Int) -> Void
    ) {
        _vm = StateObject(wrappedValue: UsersListViewModel())
        self.excludedUserIds = excludedUserIds
        self.onAddMember = onAddMember
    }

    // Liste des utilisateurs filtrés et triés
    var filteredUsers: [ProfileResponse] {
        vm.users
            .filter { !excludedUserIds.contains($0.id) }
            .sorted { $0.lastName < $1.lastName }
    }

    var body: some View {
        ZStack {
            
            // Fond personnalisé
            BackgroundView(ecran: .users)

            // Chargement
            if vm.isLoading {
                ProgressView()

            // Erreur
            } else if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)

            // Aucun utilisateur disponible
            } else if filteredUsers.isEmpty {
                Text("Aucun utilisateur à ajouter")
                    .foregroundColor(.secondary)
                    .font(.caption)

            // Liste des utilisateurs
            } else {
                List(filteredUsers) { user in
                    
                    // Ligne utilisateur
                    ProfileRowView(user: user, isOwner: false)
                    
                        // Action swipe → Ajouter
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                onAddMember(user.id)
                                dismiss()
                            } label: {
                                Label("Ajouter", systemImage: "plus.app")
                            }
                            .tint(.green)
                        }
                        .onTapGesture {
                            onAddMember(user.id)
                            dismiss()
                        }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .appNavigationTitle("Ajouter un membre")
        .logLifecycle("ProjectUserSelectionView")
        // Chargement initial des utilisateurs
        .task {
            await vm.fetchUsersList()
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
