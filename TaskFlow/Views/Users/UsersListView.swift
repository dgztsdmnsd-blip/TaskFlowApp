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

    // PROD
    init(currentUser: ProfileResponse) {
        self.currentUser = currentUser
        _vm = StateObject(wrappedValue: UsersListViewModel())
    }

    // PREVIEW / TEST
    init(
        currentUser: ProfileResponse,
        vm: UsersListViewModel
    ) {
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
                        NavigationLink {
                            UserDetailView(currentUser: currentUser, user: user)
                        } label: {
                            userRow(user: user)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
            }
        }
        .onAppear {
            guard !ProcessInfo.isRunningPreviews else { return }
            Task { await vm.fetchUsersList() }
        }
    }

    /// Ligne utilisateur
    private func userRow(user: ProfileResponse) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                    .font(.caption)

                Text(user.email)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(user.profil == "MGR" ? "Manager" : "Utilisateur")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    user.profil == "MGR"
                        ? Color.blue.opacity(0.2)
                        : Color.gray.opacity(0.2)
                )
                .foregroundColor(
                    user.profil == "MGR" ? .blue : .gray
                )
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }

}

#Preview {
    NavigationStack {
        UsersListView(
            currentUser: .preview,
            vm: UsersListViewModel.preview()
        )
    }
}
