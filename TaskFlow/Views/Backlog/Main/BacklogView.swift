//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct BacklogView: View {

    @StateObject private var vm: ProjectListViewModel
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // INIT PROD
    init(etatUS: StoryStatus = .inProgress) {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // INIT PREVIEW / TEST
    init(
        vm: ProjectListViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
    }
    

    var body: some View {
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
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.projects) { project in
                            BacklogProjetsView(
                                project: project,
                                isOwner: project.owner.id == sessionVM.currentUser?.id
                            )
                            .padding()
                        }
                    }
                }
            }
        }
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchActiveProjects()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .projectListShouldRefresh)
        ) { _ in
            Task { await vm.fetchActiveProjects() }
        }
    }
}
