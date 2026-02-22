//
//  TaskFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//
//  ViewModel gérant la logique du formulaire de tâche.
//  Supporte :
//  - Création d’une tâche
//  - Édition d’une tâche existante
//  - Validation et gestion des états UI
//

import Foundation
import Combine

// ViewModel du formulaire de tâche
@MainActor
final class TaskFormViewModel: ObservableObject {

    // Mode du formulaire (create / edit)
    let mode: TaskMode
    
    // User story associée à la tâche
    let userStory: StoryResponse

    // Champs du formulaire
    @Published var titre = ""
    @Published var description = ""
    @Published var type: String = ""
    @Published var storyPoint: Int?

    // États UI
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    // Validation du formulaire
    var isFormValid: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !type.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Indique si le formulaire est en mode édition
    var isEditing: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    init(mode: TaskMode, userStory: StoryResponse) {
        self.mode = mode
        self.userStory = userStory

        // Pré-remplissage en mode édition
        if case .edit(let task) = mode {
            titre = task.title
            description = task.description
            type = task.type
            storyPoint = task.storyPoint
        }
    }

    // Soumet le formulaire (création / mise à jour)
    func submit() async {
        isLoading = true
        isSuccess = false
        errorMessage = nil
        defer { isLoading = false }

        // Validation locale
        guard isFormValid else {
            errorMessage = "Veuillez remplir le titre, la description et le type de tâche."
            return
        }

        do {
            switch mode {

            case .create:
                // Création d’une nouvelle tâche
                _ = try await TaskService.shared.createTask(
                    userStoryId: userStory.id,
                    title: titre,
                    description: description,
                    type: type,
                    storyPoint: storyPoint
                )

            case .edit(let task):
                // Mise à jour d’une tâche existante
                _ = try await TaskService.shared.updateTask(
                    taskId: task.id,
                    title: titre,
                    description: description,
                    type: type,
                    storyPoint: storyPoint
                )

            case .liste:
                // Non utilisé ici
                break
            }

            // Succès
            isSuccess = true

        } catch {
            // Erreur générique (réseau / validation backend)
            errorMessage = "Erreur réseau ou validation."
        }
    }
}
