//
//  UsersListView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//

import SwiftUI

struct UsersListView: View {

    @StateObject private var vm: UsersListViewModel
    let currentUser: ProfileResponse
    
    @State private var selectedUser: ProfileResponse?

    init(currentUser: ProfileResponse) {
        self.currentUser = currentUser
        _vm = StateObject(wrappedValue: UsersListViewModel())
    }

    init(currentUser: ProfileResponse, vm: UsersListViewModel) {
        self.currentUser = currentUser
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .users)

            VStack {
                if vm.isLoading {
                    ProgressView()

                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if vm.users.isEmpty {
                    Text("Aucun utilisateur trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                } else {
                    List(vm.users) { user in
                        Button {
                            selectedUser = user
                        } label: {
                            ProfileRowView(user: user, isOwner: false)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationDestination(item: $selectedUser) { user in
            UserDetailView(currentUser: currentUser, user: user)
        }
        .onAppear {
            guard !ProcessInfo.isRunningPreviews else { return }
            Task { await vm.fetchUsersList() }
        }
    }
}
