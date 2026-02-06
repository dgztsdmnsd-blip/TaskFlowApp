//
//  ProjectUsersView.swift
//  TaskFlow
//
//  Created by luc banchetti on 04/02/2026.
//

import SwiftUI

struct ProjectUsersView: View {

    @StateObject private var vm: ProjectUsersViewModel
    @Environment(\.dismiss) private var dismiss

    // UI
    @State private var showAddMember = false

    // INIT PROD
    init(project: ProjectResponse) {
        _vm = StateObject(
            wrappedValue: ProjectUsersViewModel(projectId: project.id)
        )
    }

    // INIT PREVIEW / TEST
    init(vm: ProjectUsersViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .projets)

            VStack(spacing: 12) {

                if vm.isLoading {
                    ProgressView()

                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if vm.members.isEmpty {
                    Text("Aucun membre trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                } else {
                    List {
                        ForEach(vm.members) { member in
                            let isOwner = (vm.ownerId == member.id)

                            ProfileRowView(user: member, isOwner: isOwner)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if !isOwner {
                                        Button(role: .destructive) {
                                            Task {
                                                await vm.removeMember(userId: member.id)
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
        .navigationTitle("Membres du projet")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchMembers()
        }
        .sheet(isPresented: $showAddMember) {
            NavigationStack {
                ProjectUserSelectionView(
                    excludedUserIds: Set(vm.members.map(\.id)),
                    onAddMember: { userId in
                        Task {
                            await vm.addMember(userId: userId)
                            showAddMember = false
                        }
                    }
                )
            }
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
        ProjectUsersView(
            vm: ProjectUsersViewModel(projectId: 1)
        )
    }
}
