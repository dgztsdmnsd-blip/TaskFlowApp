//
//  TasksSectionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//

import SwiftUI

struct TasksSectionView: View {

    let story: StoryResponse
    @ObservedObject var tasksVM: UserStoryTasksViewModel

    let onAddTask: () -> Void
    let onDeleteTask: (Int) -> Void
    let onTaskUpdated: (() -> Void)?

    @EnvironmentObject private var session: SessionViewModel
    @State private var selectedTaskId: Int?

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

            Label("Tâches", systemImage: "checklist")
                .font(.headline)

            if tasksVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            if tasksVM.todo.isEmpty &&
               tasksVM.doing.isEmpty &&
               tasksVM.done.isEmpty &&
               !tasksVM.isLoading {

                Text("Aucune tâche pour cette user story.")
                    .font(.caption)
                    .foregroundColor(.secondary)

            } else {

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
        .cardStyleView()
        .navigationDestination(item: $selectedTaskId) { taskId in
            TaskDetailView(taskId: taskId)
        }
        .onReceive(NotificationCenter.default.publisher(for: .taskDidChange)) { _ in
            Task {
                await tasksVM.loadTasksByStatus()
            }
        }
    }

    private var canEditTasks: Bool {
        story.owner.id == session.currentUser?.id
    }

    private func delete(_ taskId: Int) {
        Task {
            try? await TaskService.shared.deleteTask(taskId: taskId)
            onDeleteTask(taskId)
        }
    }
}
