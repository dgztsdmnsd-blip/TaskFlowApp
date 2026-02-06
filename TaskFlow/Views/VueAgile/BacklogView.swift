//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct BacklogView: View {

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
                        projectRow(project: project)}
                    .scrollContentBackground(.hidden)
                }
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


#Preview {
    NavigationStack {
        ProjectsView(
            vm: ProjectListViewModel.preview()
        )
    }
}
