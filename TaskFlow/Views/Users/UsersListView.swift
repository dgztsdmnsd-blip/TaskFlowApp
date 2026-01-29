//
//  UsersListView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//

import SwiftUI

struct UsersListView: View {

    // ViewModel
    @StateObject private var ulm = UsersListViewModel()
    let currentUser: ProfileResponse

    var body: some View {
        ZStack {
            BackgroundView(ecran: .enCours)
            VStack {
                
                if ulm.isLoading {
                    ProgressView()

                } else if let error = ulm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if ulm.users.isEmpty {
                    Text("Aucun utilisateur trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                } else {
                    List(ulm.users) { user in
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
            Task {
                await ulm.fetchUsersList()
            }
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
