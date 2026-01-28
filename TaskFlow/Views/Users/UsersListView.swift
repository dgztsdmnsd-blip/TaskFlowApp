//
//  UsersListView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//

import SwiftUI

import SwiftUI

struct UsersListView: View {

    // Fermeture de la sheet
    @Environment(\.dismiss) private var dismiss

    // ViewModel
    @StateObject private var ulm = UsersListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

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
                        userRow(user: user)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Utilisateurs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.app.fill")
                            .foregroundStyle(.blue)
                    }
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
                    .font(.headline)

                Text(user.email)
                    .font(.subheadline)
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
        .padding(.vertical, 6)
    }

}


#Preview {
    UsersListView()
}
