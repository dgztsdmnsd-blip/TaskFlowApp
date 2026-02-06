//
//  UserProjetsView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct UserProjectsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sessionVM: SessionViewModel

    @StateObject private var vm: UserProjectsViewModel
    @StateObject private var vmo: OwnerProjectsViewModel
    
    private var assignedProjectIds: Set<Int> {
        Set(vm.projects.map(\.id))
    }

    private var availableProjects: [ProjectResponse] {
        vmo.projects.filter {
            !assignedProjectIds.contains($0.id)
        }
    }


    init(
        userId: Int,
        vm: UserProjectsViewModel? = nil,
        vmo: OwnerProjectsViewModel? = nil
    ) {
        _vm = StateObject(
            wrappedValue: vm ?? UserProjectsViewModel(userId: userId)
        )
        _vmo = StateObject(
            wrappedValue: vmo ?? OwnerProjectsViewModel()
        )
    }

    var body: some View {
        ZStack {
            BackgroundView(ecran: .projets)

            VStack {
                if vm.isLoading {
                    ProgressView()

                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if vm.projects.isEmpty {
                    Text("Aucun projet trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                } else {
                    VStack {
                        List {
                            Section("Projets attribués") {
                                ForEach(vm.projects) { project in
                                    ProjectsRowView(
                                        project: project,
                                        isOwner: project.owner.id == sessionVM.currentUser?.id
                                    )
                                }
                            }

                            Section("Attribuer de nouveaux projets") {
                                ForEach(availableProjects) { project in
                                    ProjectsRowView(
                                        project: project,
                                        isOwner: project.owner.id == sessionVM.currentUser?.id
                                    )
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            Task {
                                                await vm.assignProjectToUser(projectId: project.id)
                                            }
                                        } label: {
                                            Label("Ajouter", systemImage: "plus.app")
                                        }
                                        .tint(.green)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
        .navigationTitle("Projets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.app.fill")
                }
            }
        }
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchProjects()
            await vmo.fetchProjects()
        }
    }
}
/* TODO: A corriger
#Preview {
    NavigationStack {
        UserProjectsView(
            userId: 1,
            vm: .preview,
            vmo: .preview
        )
        .environmentObject(SessionViewModel.mock)
    }
}*/
