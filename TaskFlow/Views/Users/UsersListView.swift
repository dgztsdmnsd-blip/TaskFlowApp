//
//  UsersListView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//
//  Vue affichant la liste des utilisateurs.
//

import SwiftUI

struct UsersListView: View {

    // ViewModel liste utilisateurs
    @StateObject private var vm: UsersListViewModel
    
    // Utilisateur actuellement connecté
    let currentUser: ProfileResponse
    
    // Utilisateur sélectionné (navigation détail)
    @State private var selectedUser: ProfileResponse?

    // Init
    init(currentUser: ProfileResponse) {
        self.currentUser = currentUser
        
        // Initialisation VM standard
        _vm = StateObject(
            wrappedValue: UsersListViewModel()
        )
    }

    // Init avec injection VM (preview / tests)
    init(currentUser: ProfileResponse, vm: UsersListViewModel) {
        self.currentUser = currentUser
        
        _vm = StateObject(
            wrappedValue: vm
        )
    }

    // Body
    var body: some View {
        ZStack {

            // Fond dégradé écran Users
            BackgroundView(ecran: .users)

            VStack {

                // Chargement API
                if vm.isLoading {
                    ProgressView()

                // Erreur API
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                // Aucun utilisateur
                } else if vm.users.isEmpty {
                    Text("Aucun utilisateur trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                // Liste utilisateurs
                } else {
                    List(vm.users) { user in

                        // Navigation vers détail utilisateur
                        Button {
                            selectedUser = user

                        } label: {
                            ProfileRowView(
                                user: user,
                                isOwner: false
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        // Navigation vers UserDetailView
        .navigationDestination(item: $selectedUser) { user in
            UserDetailView(
                currentUser: currentUser,
                user: user
            )
        }
        // Debug lifecycle
        .logLifecycle("UserListView")
        // Chargement initial
        .onAppear {
            Task {
                await vm.fetchUsersList()
            }
        }
    }
}
