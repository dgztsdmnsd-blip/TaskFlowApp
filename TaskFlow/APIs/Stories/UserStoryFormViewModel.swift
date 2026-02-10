//
//  UserStoryFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import Foundation
import Combine

@MainActor
final class UserStoryFormViewModel: ObservableObject {

    let mode: StoryMode
    let project: ProjectResponse
    let owner: ProfileLiteResponse

    @Published var titre = ""
    @Published var description = ""
    @Published var dueAt: String?
    @Published var priority: Int?
    @Published var storyPoint: Int?
    @Published var couleur = "#000000"

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    var isFormValid: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        mode: StoryMode,
        project: ProjectResponse,
        owner: ProfileLiteResponse
    ) {
        self.mode = mode
        self.project = project
        self.owner = owner

        if case .edit(let story) = mode {
            titre = story.title
            description = story.description
            dueAt = story.dueAt
            priority = story.priority
            storyPoint = story.storyPoint
            couleur = story.couleur
        }
    }

    func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            return
        }

        do {
            switch mode {
            case .create:
                _ = try await StoriesService.shared.createUserStory(
                    projectId: project.id,
                    title: titre,
                    description: description,
                    dueAt: dueAt,
                    priority: priority,
                    storyPoint: storyPoint,
                    couleur: couleur
                )

            case .edit(let story):
                _ = try await StoriesService.shared.updateUserStory(
                    userStoryId: story.id,
                    title: titre,
                    description: description,
                    dueAt: dueAt,
                    priority: priority,
                    storyPoint: storyPoint,
                    couleur: couleur
                )

            case .liste:
                break
            }

            isSuccess = true

        } catch {
            errorMessage = "Erreur réseau ou validation."
        }
    }
}
