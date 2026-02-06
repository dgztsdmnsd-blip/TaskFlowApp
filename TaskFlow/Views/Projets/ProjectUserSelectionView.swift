//
//  ProjectUserSelectionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct ProjectUserSelectionView: View {

    @StateObject private var vm: UsersListViewModel

    let excludedUserIds: Set<Int>
    let onAddMember: (Int) -> Void

    @Environment(\.dismiss) private var dismiss


    // PREVIEW / TEST
    init(
        vm: UsersListViewModel,
        excludedUserIds: Set<Int> = [],
        onAddMember: @escaping (Int) -> Void = { _ in }
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.excludedUserIds = excludedUserIds
        self.onAddMember = onAddMember
    }
    
    // INIT PROD
    init(
        excludedUserIds: Set<Int>,
        onAddMember: @escaping (Int) -> Void
    ) {
        _vm = StateObject(wrappedValue: UsersListViewModel())
        self.excludedUserIds = excludedUserIds
        self.onAddMember = onAddMember
    }


    var filteredUsers: [ProfileResponse] {
        vm.users
            .filter { !excludedUserIds.contains($0.id) }
            .sorted { $0.lastName < $1.lastName }
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .users)

            if vm.isLoading {
                ProgressView()

            } else if let error = vm.errorMessage {
                Text(error).foregroundColor(.red).font(.caption)

            } else if filteredUsers.isEmpty {
                Text("Aucun utilisateur à ajouter")
                    .foregroundColor(.secondary)
                    .font(.caption)

            } else {
                List(filteredUsers) { user in
                    ProfileRowView(user: user, isOwner: false)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                onAddMember(user.id)
                                dismiss()
                            } label: {
                                Label("Ajouter", systemImage: "plus.app")
                            }
                            .tint(.green)
                        }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Ajouter un membre")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchUsersList()
        }
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
        ProjectUserSelectionView(
            vm: UsersListViewModel.preview(),
            excludedUserIds: [15, 18], 
            onAddMember: { id in
                print("add member \(id)")
            }
        )
    }
}
