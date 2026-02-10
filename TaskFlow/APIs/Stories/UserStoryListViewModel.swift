//
//  UserStoryListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import Foundation
import Combine

@MainActor
final class UserStoryListViewModel: ObservableObject {

    @Published var stories: [StoryResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Liste des user stories de l'utilisateur connecté (owner)
    func fetchStories(
        projectId: Int,
        statut: StoryStatus
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            stories = try await StoriesService.shared.listOwnerUserStory(projectId: projectId, statut: statut)
        } catch APIError.httpError(let code, let message) {
            print("HTTP ERROR:", code, message ?? "")
            errorMessage = message ?? "Erreur lors du chargement des user stories."
        } catch {
            errorMessage = "Erreur réseau."
        }


        isLoading = false
    }
}
