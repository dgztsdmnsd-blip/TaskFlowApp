//
//  ProjectsView.swift
//  TaskFlow
//

import SwiftUI

struct ProjectsView: View {

    @StateObject private var vm: ProjectListViewModel

    // INIT PROD
    init() {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // INIT PREVIEW / TEST
    init(vm: ProjectListViewModel) {
        _vm = StateObject(wrappedValue: vm)
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
                    List(vm.projects) { project in
                        NavigationLink {
                            ProjectDetailView(
                                vm: ProjectDetailViewModel(project: project)
                            )
                        } label: {
                            projectRow(project: project)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchProjects()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .projectListShouldRefresh
            )
        ) { _ in
            Task { await vm.fetchProjects() }
        }
    }

    // Row
    private func projectRow(project: ProjectResponse) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)

                Text(project.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text(
                    project.membersCount == 1
                    ? "1 membre"
                    : "\(project.membersCount) membres"
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(project.status.color)
                    .frame(width: 8, height: 8)

                Text(project.status.label)
                    .font(.caption.bold())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(project.status.color.opacity(0.15))
            .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}


extension Notification.Name {
    /// Demande de rafraîchissement de la liste des projets
    static let projectListShouldRefresh =
        Notification.Name("projectListShouldRefresh")
}


extension ProcessInfo {
    static var isRunningPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


#Preview {
    NavigationStack {
        ProjectsView(
            vm: ProjectListViewModel.preview()
        )
    }
}
