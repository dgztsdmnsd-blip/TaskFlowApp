//
//  TasksSectionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//
//  Section affichant les tâches d’une User Story.
//  Permet :
//  - Visualisation par colonnes (À faire / En cours / Terminé)
//  - Ajout / suppression
//  - Navigation vers détail tâche
//

import SwiftUI

struct TasksSectionView: View {

    // Story associée
    let story: StoryResponse

    // ViewModel des tâches
    @ObservedObject var tasksVM: UserStoryTasksViewModel

    // Callbacks actions
    let onAddTask: () -> Void
    let onDeleteTask: (Int) -> Void
    let onTaskUpdated: (() -> Void)?

    // Session utilisateur globale
    @EnvironmentObject private var session: SessionViewModel

    // Tâche sélectionnée pour navigation
    @State private var selectedTaskId: Int?

    // Initialisation
    init(
        story: StoryResponse,
        tasksVM: UserStoryTasksViewModel,
        onAddTask: @escaping () -> Void,
        onDeleteTask: @escaping (Int) -> Void,
        onTaskUpdated: (() -> Void)? = nil
    ) {
        self.story = story
        self.tasksVM = tasksVM
        self.onAddTask = onAddTask
        self.onDeleteTask = onDeleteTask
        self.onTaskUpdated = onTaskUpdated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Section Title
            Label("Tâches", systemImage: "checklist")
                .font(.headline)

            // Loading State
            if tasksVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            // Empty State
            if tasksVM.todo.isEmpty &&
               tasksVM.doing.isEmpty &&
               tasksVM.done.isEmpty &&
               !tasksVM.isLoading {

                Text("Aucune tâche pour cette user story.")
                    .font(.caption)
                    .foregroundColor(.secondary)

            } else {

                // Tasks Columns
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {

                        TaskColumnView(
                            title: "À faire",
                            status: .notStarted,
                            tasks: tasksVM.todo,
                            tasksVM: tasksVM,
                            selectedTaskId: $selectedTaskId
                        )

                        TaskColumnView(
                            title: "En cours",
                            status: .inProgress,
                            tasks: tasksVM.doing,
                            tasksVM: tasksVM,
                            selectedTaskId: $selectedTaskId
                        )

                        TaskColumnView(
                            title: "Terminé",
                            status: .finished,
                            tasks: tasksVM.done,
                            tasksVM: tasksVM,
                            selectedTaskId: $selectedTaskId
                        )
                    }
                }
            }

            // Add Task Button
            if canEditTasks {
                BoutonImageView(
                    title: "Ajouter une tâche",
                    systemImage: "checklist",
                    style: .secondary
                ) {
                    onAddTask()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // Debug Lifecycle
        .logLifecycle("TasksSectionView")
        // Style Card
        .cardStyleView()
        // Navigation vers détail tâche
        .navigationDestination(item: $selectedTaskId) { taskId in
            TaskDetailView(taskId: taskId)
        }
        // Notifications
        .onReceive(NotificationCenter.default.publisher(for: .taskDidChange)) { _ in
            Task {
                await tasksVM.loadTasksByStatus()
            }
        }
    }

    // Autorise l’édition uniquement pour le owner de la story
    private var canEditTasks: Bool {
        story.owner.id == session.currentUser?.id
    }

    // Suppression d’une tâche
    private func delete(_ taskId: Int) {
        Task {
            try? await TaskService.shared.deleteTask(taskId: taskId)
            onDeleteTask(taskId)
        }
    }
}
