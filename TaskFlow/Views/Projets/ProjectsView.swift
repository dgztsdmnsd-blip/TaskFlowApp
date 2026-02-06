//
//  ProjectsView.swift
//  TaskFlow
//

import SwiftUI

struct ProjectsView: View {

    @EnvironmentObject private var sessionVM: SessionViewModel
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
                            ProjectsRowView(
                                project: project,
                                isOwner: project.owner.id == sessionVM.currentUser?.id
                            )
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
        .environmentObject({
            let vm = SessionViewModel()
            vm.currentUser = .preview   
            vm.isAuthenticated = true
            return vm
        }())
    }
}

