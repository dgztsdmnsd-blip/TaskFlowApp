//
//  UserStoryTasksViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import Foundation
import Combine

@MainActor
final class UserStoryTasksViewModel: ObservableObject {

    @Published var tasks: [TaskListResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userStoryId: Int
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }

        let finishedCount = tasks.filter { $0.status == .finished }.count
        return Double(finishedCount) / Double(tasks.count)
    }

    init(userStoryId: Int) {
        self.userStoryId = userStoryId
    }

    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tasks = try await TaskService.shared.listTasks(
                userStoryId: userStoryId
            )
        } catch {
            errorMessage = "Impossible de charger les tâches."
        }
    }

    func removeTask(id: Int) {
        tasks.removeAll { $0.id == id }
    }
}
