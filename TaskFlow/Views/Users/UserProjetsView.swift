//
//  UserProjectsView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//
//  Vue permettant de visualiser et attribuer
//  des projets à un utilisateur.
//

import SwiftUI

struct UserProjectsView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sessionVM: SessionViewModel

    @StateObject private var vm: UserProjectsViewModel
    @StateObject private var vmo: OwnerProjectsViewModel

    // IDs des projets déjà assignés
    private var assignedProjectIds: Set<Int> {
        var ids = Set<Int>()
        for project in vm.projects {
            ids.insert(project.id)
        }
        return ids
    }

    // Projets disponibles
    private var availableProjects: [ProjectResponse] {
        vmo.projects.filter { project in
            !assignedProjectIds.contains(project.id)
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

        let projectsDisponibles = availableProjects
        let isLoading = vm.isLoading
        let errorMessage = vm.errorMessage
        let userProjects = vm.projects

        ZStack {
            BackgroundView(ecran: .projets)

            VStack {

                if isLoading {
                    ProgressView()

                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if userProjects.isEmpty {
                    Text("Aucun projet trouvé")
                        .foregroundColor(.secondary)
                        .font(.caption)

                } else {

                    List {

                        Section {
                            ForEach(userProjects) { project in
                                assignedRow(project)
                            }
                        } header: {
                            Text("Projets attribués")
                                .adaptiveTextColor()
                        }

                        Section {
                            ForEach(projectsDisponibles) { project in
                                availableRow(project)
                            }
                        } header: {
                            Text("Attribuer de nouveaux projets")
                                .adaptiveTextColor()
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .appNavigationTitle("Projets")
        .logLifecycle("UserProjectsView")
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
            await vm.fetchProjects()
            await vmo.fetchProjects()
        }
    }

    // Rows
    private func assignedRow(_ project: ProjectResponse) -> some View {
        ProjectsRowView(
            project: project,
            isOwner: project.owner.id == sessionVM.currentUser?.id
        )
    }

    private func availableRow(_ project: ProjectResponse) -> some View {
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
