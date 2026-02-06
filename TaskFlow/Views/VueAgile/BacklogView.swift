//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct BacklogView: View {

    let etatUS: UserStoriesStatus
    @StateObject private var vm: ProjectListViewModel

    // INIT PROD
    init(etatUS: UserStoriesStatus = .enCours) {
        self.etatUS = etatUS
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // INIT PREVIEW / TEST
    init(
        etatUS: UserStoriesStatus = .enCours,
        vm: ProjectListViewModel
    ) {
        self.etatUS = etatUS
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
                List(vm.projects) { project in
                    projectRow(project: project)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchActiveProjects()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .projectListShouldRefresh
            )
        ) { _ in
            Task { await vm.fetchActiveProjects() }
        }
    }
        
    // Row
    private func projectRow(project: ProjectResponse) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)

                Text(
                    project.membersCount == 1
                    ? "1 membre"
                    : "\(project.membersCount) membres"
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        BacklogView(
            etatUS: .enCours,
            vm: ProjectListViewModel.preview()
        )
    }
}
