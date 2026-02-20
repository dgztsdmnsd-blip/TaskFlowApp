//
//  UserStoryColumnView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Colonne Kanban des User Stories.
//  Affiche les stories selon :
//  - Projet
//  - Statut
//  - Mode filtré ou API
//

import SwiftUI

struct UserStoryColumnView: View {

    // Inputs
    let projectId: Int
    let title: String
    let statut: StoryStatus
    let owner: Bool

    // nil → chargement API normal
    // non-nil → mode filtré (tags / recherche)
    let filteredStories: [StoryResponse]?

    @StateObject private var vm = UserStoryListViewModel()
    @State private var isTargeted = false

    @Environment(\.horizontalSizeClass) private var sizeClass


    // Indique si la colonne est en mode filtré
    private var isFiltering: Bool {
        filteredStories != nil
    }

    // Stories réellement affichées dans la colonne
    private var displayedStories: [StoryResponse] {

        if let filteredStories {
            let result = filteredStories.filter {
                $0.project.id == projectId && $0.status == statut
            }

            if AppConfig.version == .dev {
                print("Column \(title) [FILTERED] →", result.map(\.id))
            }
            
            return result
        }

        if AppConfig.version == .dev {
            print("Column \(title) [VM] →", vm.stories.map(\.id))
        }
        
        return vm.stories
    }

    // Body
    var body: some View {

        let stories = displayedStories
        let cardSize = UIConstants.cardSize(for: sizeClass)

        return VStack(alignment: .leading, spacing: 8) {

            // Column Title
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)

            VStack(spacing: 8) {

                // Loading State
                if vm.isLoading && !isFiltering {
                    ProgressView()

                // Error State
                } else if let error = vm.errorMessage, !isFiltering {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)

                // Empty State
                } else if stories.isEmpty {
                    Text(isFiltering ? "Aucune user story" : "Déposer ici")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: cardSize.width, height: cardSize.height)

                // Stories List
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
            // Column Background
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isTargeted
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.05)
                    )
            )
            .animation(.easeInOut, value: isTargeted)
            // Drag & Drop
            .dropDestination(
                for: DraggableStory.self,
                action: handleDrop,
                isTargeted: { targeted in
                    isTargeted = targeted
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        // Debug Lifecycle
        .logLifecycle("UserStoryColumnView")
        // Chargement initial
        .task {
            await loadStoriesIfNeeded()
        }
        // Notifications
        .onReceive(NotificationCenter.default.publisher(for: .userStoryStatusDidChange)) { _ in
            Task { await refreshIfNeeded() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userStoryDidChange)) { _ in
            Task { await refreshIfNeeded() }
        }
        // Debug Info
        .onAppear {
            if AppConfig.version == .dev {
                print("Column \(title)")
                print("isFiltering:", isFiltering)
                print("filteredStories:", filteredStories?.map(\.id) ?? [])
                print("vm.stories:", vm.stories.map(\.id))
            }
        }
    }
}

// Private Helpers
private extension UserStoryColumnView {
    // Charge les stories uniquement si nécessaire
    func loadStoriesIfNeeded() async {
        guard !isFiltering else { return }

        await fetchStories()
    }

    // Rafraîchit si la colonne n’est pas filtrée
    func refreshIfNeeded() async {
        guard !isFiltering else { return }
        await fetchStories()
    }

    // Chargement API selon rôle owner / membre
    func fetchStories() async {
        if owner {
            await vm.fetchAllStories(projectId: projectId, statut: statut)
        } else {
            await vm.fetchStories(projectId: projectId, statut: statut)
        }
    }

    // Gère le drop d’une User Story dans la colonne
    func handleDrop(_ items: [DraggableStory], _ location: CGPoint) -> Bool {

        guard let item = items.first else { return false }

        Task {
            do {
                _ = try await StoriesService.shared.updateStoryStatus(
                    userStoryId: item.id,
                    status: statut
                )

                // Notifie les autres colonnes
                NotificationCenter.default.post(
                    name: .userStoryStatusDidChange,
                    object: nil
                )

            } catch {
                if AppConfig.version == .dev {
                    print("Erreur changement de statut:", error)
                }
            }
        }

        return true
    }
}
