//
//  UserStoryTasksViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  ViewModel gérant les tâches d’une user story.
//  Supporte :
//  - Chargement Kanban (ToDo / Doing / Done)
//  - Calcul de progression
//  - Déplacement optimiste
//  - Suppression locale
//

import Foundation
import Combine

// ViewModel des tâches d’une User Story (Kanban)
@MainActor
final class UserStoryTasksViewModel: ObservableObject {

    // Colonnes Kanban
    @Published var todo: [TaskListResponse] = []
    @Published var doing: [TaskListResponse] = []
    @Published var done: [TaskListResponse] = []

    // États UI
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Identifiant User Story
    let userStoryId: Int

    // Progression globale (0 → 1)
    var progress: Double {
        let allTasks = todo + doing + done
        guard !allTasks.isEmpty else { return 0 }

        return Double(done.count) / Double(allTasks.count)
    }

    // Initialisation
    init(userStoryId: Int) {
        self.userStoryId = userStoryId
    }

    // Charge les tâches par statut (Kanban)
    func loadTasksByStatus() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Chargements parallèles
            async let ns = TaskService.shared.listTasks(
                userStoryId: userStoryId,
                statut: "NS"
            )

            async let enc = TaskService.shared.listTasks(
                userStoryId: userStoryId,
                statut: "ENC"
            )

            async let ter = TaskService.shared.listTasks(
                userStoryId: userStoryId,
                statut: "TER"
            )

            // Assignation UI
            todo = try await ns
            doing = try await enc
            done = try await ter

        } catch {
            errorMessage = "Impossible de charger les tâches."

            if AppConfig.version == .dev {
                print("loadTasksByStatus ERROR:", error.localizedDescription)
            }
        }
    }

    // Suppression locale d’une tâche
    func removeTask(id: Int) {
        todo.removeAll { $0.id == id }
        doing.removeAll { $0.id == id }
        done.removeAll { $0.id == id }
    }

    // Déplacement optimiste d’une tâche
    func moveTask(taskId: Int, to newStatus: TaskStatus) {

        if let task = todo.first(where: { $0.id == taskId }) {
            todo.removeAll { $0.id == taskId }
            var updated = task
            updated.status = newStatus
            insert(updated, into: newStatus)
            return
        }

        if let task = doing.first(where: { $0.id == taskId }) {
            doing.removeAll { $0.id == taskId }
            var updated = task
            updated.status = newStatus
            insert(updated, into: newStatus)
            return
        }

        if let task = done.first(where: { $0.id == taskId }) {
            done.removeAll { $0.id == taskId }
            var updated = task
            updated.status = newStatus
            insert(updated, into: newStatus)
            return
        }
    }

    // Insertion dans la bonne colonne Kanban
    private func insert(_ task: TaskListResponse, into status: TaskStatus) {
        switch status {
        case .notStarted:
            todo.append(task)

        case .inProgress:
            doing.append(task)

        case .finished:
            done.append(task)
        }
    }
}
