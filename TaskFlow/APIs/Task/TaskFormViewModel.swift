//
//  TaskFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import Foundation
import Combine

@MainActor
final class TaskFormViewModel: ObservableObject {

    let mode: TaskMode
    let userStory: StoryResponse

    @Published var titre = ""
    @Published var description = ""
    @Published var type: String = ""
    @Published var storyPoint: Int?

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    var isFormValid: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !type.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(mode: TaskMode, userStory: StoryResponse) {
        self.mode = mode
        self.userStory = userStory

        if case .edit(let task) = mode {
            titre = task.title
            description = task.description
            type = task.type
            storyPoint = task.storyPoint
        }
    }

    func submit() async {
        isLoading = true
        isSuccess = false
        errorMessage = nil
        defer { isLoading = false }

        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            return
        }

        do {
            switch mode {
            case .create:
                _ = try await TaskService.shared.createTask(
                    userStoryId: userStory.id,
                    title: titre,
                    description: description,
                    type: type,
                    storyPoint: storyPoint
                )

            case .edit(let task):
                _ = try await TaskService.shared.updateTask(
                    taskId: task.id,
                    title: titre,
                    description: description,
                    type: type,
                    storyPoint: storyPoint
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
