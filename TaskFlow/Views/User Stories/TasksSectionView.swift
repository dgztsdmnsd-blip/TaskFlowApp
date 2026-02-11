//
//  TasksSectionView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//

import SwiftUI

import SwiftUI

struct TasksSectionView: View {

    let story: StoryResponse
    @ObservedObject var tasksVM: UserStoryTasksViewModel
    
    let onAddTask: () -> Void
    let onDeleteTask: (Int) -> Void
    
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Label("Tâches", systemImage: "checklist")
                .font(.headline)

            if tasksVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            if tasksVM.tasks.isEmpty && !tasksVM.isLoading {
                Text("Aucune tâche pour cette user story.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            List {
                ForEach(tasksVM.tasks) { task in
                    NavigationLink {
                        TaskDetailView(
                            taskId: task.id,
                            onDeleted: {
                                onDeleteTask(task.id) 
                            }
                        )
                    } label: {
                        TaskRowView(task: task)
                    }
                    .swipeActions {
                        if canEditTasks {
                            Button(role: .destructive) {
                                delete(task.id)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(height: 300)

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
