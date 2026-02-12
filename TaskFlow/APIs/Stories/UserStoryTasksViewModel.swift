//
//  UserStoryTasksViewModel.swift
//  TaskFlow
//

import Foundation
import Combine

@MainActor
final class UserStoryTasksViewModel: ObservableObject {

    // Kanban Lists
    @Published var todo: [TaskListResponse] = []
    @Published var doing: [TaskListResponse] = []
    @Published var done: [TaskListResponse] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    let userStoryId: Int

    // Progression globale
    var progress: Double {
        let allTasks = todo + doing + done
        guard !allTasks.isEmpty else { return 0 }

        let finishedCount = done.count
        return Double(finishedCount) / Double(allTasks.count)
    }

    // Init
    init(userStoryId: Int) {
        self.userStoryId = userStoryId
    }

    // Chargement Kanban
    func loadTasksByStatus() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
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

            todo = try await ns
            doing = try await enc
            done = try await ter

        } catch {
            errorMessage = "Impossible de charger les tâches."
            print("Erreur loadTasksByStatus:", error)
        }
    }

    // Suppression locale
    func removeTask(id: Int) {
        todo.removeAll { $0.id == id }
        doing.removeAll { $0.id == id }
        done.removeAll { $0.id == id }
    }

    // Déplacement optimiste
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

    // Helper insertion
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
