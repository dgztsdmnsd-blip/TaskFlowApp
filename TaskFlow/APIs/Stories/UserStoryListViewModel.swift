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
    func fetchStories(projectId: Int, statut: StoryStatus) async {

        isLoading = true
        errorMessage = nil

        print("fetchStories START → project:", projectId, "status:", statut)

        do {
            let fetchedStories = try await StoriesService.shared
                .listOwnerUserStory(projectId: projectId, statut: statut)

            print("fetchStories RESPONSE →", fetchedStories.map(\.id))
            print("BEFORE assign →", stories.map(\.id))
            stories = fetchedStories
            print("AFTER assign →", stories.map(\.id))
            print("vm.stories UPDATED →", stories.map(\.id))

        } catch APIError.httpError(let code, let message) {
            print("HTTP ERROR:", code, message ?? "")
            errorMessage = message ?? "Erreur lors du chargement des user stories."

        } catch {
            if (error as NSError).code == NSURLErrorCancelled {
                print("fetchStories CANCELLED (normal SwiftUI lifecycle)")
                isLoading = false
                return
            }

            print("fetchStories ERROR →", error)
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }

    
    // Liste des user stories de l'utilisateur connecté (owner)
    func fetchAllStories(
        projectId: Int,
        statut: StoryStatus
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedStories = try await StoriesService.shared
                .listAllUserStories(projectId: projectId, statut: statut)

            print("fetchAllStories RESPONSE →", fetchedStories.map(\.id))
            print("BEFORE assign →", stories.map(\.id))

            stories = fetchedStories

            print("AFTER assign →", stories.map(\.id))
            print("vm.stories UPDATED →", stories.map(\.id))
        }
 catch APIError.httpError(let code, let message) {
            print("HTTP ERROR:", code, message ?? "")
            errorMessage = message ?? "Erreur lors du chargement des user stories."
        } catch {
            errorMessage = "Erreur réseau."
        }


        isLoading = false
    }
}
