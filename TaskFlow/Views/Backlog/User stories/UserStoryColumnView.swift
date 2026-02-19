//
//  UserStoryColumnView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct UserStoryColumnView: View {

    // Inputs
    let projectId: Int
    let title: String
    let statut: StoryStatus
    let owner: Bool
    
    // State
    @StateObject private var vm = UserStoryListViewModel()
    @State private var isTargeted = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    /// nil → fonctionnement normal (API)
    /// non-nil → mode filtré
    let filteredStories: [StoryResponse]?
    
    // Computed
    private var isFiltering: Bool {
        filteredStories != nil
    }

    private var displayedStories: [StoryResponse] {

        if let filteredStories {
            let result = filteredStories.filter {
                $0.project.id == projectId && $0.status == statut
            }

            print("Column \(title) [FILTERED] →", result.map(\.id))
            return result
        }

        print("Column \(title) [VM] →", vm.stories.map(\.id))
        return vm.stories
    }


    // Body
    var body: some View {

        let stories = displayedStories
        let cardSize = UIConstants.cardSize(for: sizeClass)

        return VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)

            VStack(spacing: 8) {

                if vm.isLoading && !isFiltering {
                    ProgressView()

                } else if let error = vm.errorMessage, !isFiltering {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)

                } else if stories.isEmpty {
                    Text(isFiltering ? "Aucune user story" : "Déposer ici")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: cardSize.width, height: cardSize.height)
                } else {
                    ForEach(stories) { story in
                        BacklogUSView(
                            story: story,
                            isFiltering: isFiltering
                        )
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
                action: handleDrop,
                isTargeted: { targeted in
                    isTargeted = targeted
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .logLifecycle("UserStoryColumnView")
        .task {
            await loadStoriesIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: .userStoryStatusDidChange)) { _ in
            Task { await refreshIfNeeded() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userStoryDidChange)) { _ in
            Task { await refreshIfNeeded() }
        }
        .onAppear {
            print("Column \(title)")
            print("isFiltering:", filteredStories != nil)
            print("filteredStories:", filteredStories?.map(\.id) ?? [])
            print("vm.stories:", vm.stories.map(\.id))
        }

    }

}

private extension UserStoryColumnView {

    // Data Loading
    func loadStoriesIfNeeded() async {
        guard !ProcessInfo.isRunningPreviews else { return }
        guard !isFiltering else { return }

        await fetchStories()
    }

    func refreshIfNeeded() async {
        guard !isFiltering else { return }
        await fetchStories()
    }

    func fetchStories() async {
        if owner {
            await vm.fetchAllStories(projectId: projectId, statut: statut)
        } else {
            await vm.fetchStories(projectId: projectId, statut: statut)
        }
    }

    // Drop

    func handleDrop(_ items: [DraggableStory], _ location: CGPoint) -> Bool {
        guard let item = items.first else { return false }

        Task {
            do {
                _ = try await StoriesService.shared.updateStoryStatus(
                    userStoryId: item.id,
                    status: statut
                )

                NotificationCenter.default.post(
                    name: .userStoryStatusDidChange,
                    object: nil
                )

            } catch {
                print("Erreur changement de statut:", error)
            }
        }

        return true
    }
}
