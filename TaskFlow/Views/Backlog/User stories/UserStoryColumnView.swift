//
//  UserStoryColumnView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct UserStoryColumnView: View {

    let projectId: Int
    let title: String
    let statut: StoryStatus
    let owner: Bool

    @StateObject private var vm = UserStoryListViewModel()
    @State private var isTargeted = false

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            // Titre colonne
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)

            VStack(spacing: 8) {

                if vm.isLoading {
                    ProgressView()

                } else if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)

                } else if vm.stories.isEmpty {
                    Text("Déposer ici")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 80)

                } else {
                    ForEach(vm.stories) { story in
                        BacklogUSView(
                            story: story)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isTargeted
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.05)
                    )
            )
            .animation(.easeInOut, value: isTargeted)
            .dropDestination(
                for: DraggableStory.self,
                action: { items, _ in
                    Task {
                        await handleDrop(items)
                    }
                    return true
                },
                isTargeted: { targeted in
                    isTargeted = targeted
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            if owner {
                await vm.fetchAllStories(projectId: projectId, statut: statut)
            } else {
                await vm.fetchStories(projectId: projectId, statut: statut)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .userStoryStatusDidChange)
        ) { _ in
            Task {
                if owner {
                    await vm.fetchAllStories(projectId: projectId, statut: statut)
                } else {
                    await vm.fetchStories(projectId: projectId, statut: statut)
                }
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .userStoryDidChange)
        ) { _ in
            Task {
                if owner {
                    await vm.fetchAllStories(projectId: projectId, statut: statut)
                } else {
                    await vm.fetchStories(projectId: projectId, statut: statut)
                }
            }
        }

    }

    // Drop handler
    private func handleDrop(_ items: [DraggableStory]) async {
        guard let item = items.first else { return }

        do {
            _ = try await StoriesService.shared.updateStoryStatus(
                userStoryId: item.id,
                status: statut
            )

            // Refresh toutes les colonnes
            NotificationCenter.default.post(
                name: .userStoryStatusDidChange,
                object: nil
            )

        } catch {
            print("Erreur changement de statut")
        }
    }
}
