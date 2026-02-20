//
//  TaskColumnView.swift
//  TaskFlow
//
//  Colonne Kanban affichant les tâches par statut
//

import SwiftUI

struct TaskColumnView: View {

    // Titre de la colonne
    let title: String
    
    // Statut cible (todo / doing / done)
    let status: TaskStatus
    
    // Liste des tâches à afficher
    let tasks: [TaskListResponse]
    
    // ViewModel des tâches
    @ObservedObject var tasksVM: UserStoryTasksViewModel

    // Navigation vers détail tâche
    @Binding var selectedTaskId: Int?
    
    // État Drag & Drop
    @State private var isTargeted = false
    
    // Adaptation taille device
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {

        // Taille adaptative des cartes
        let cardSize = UIConstants.cardSize(for: sizeClass)

        VStack(alignment: .leading, spacing: 8) {

            // Titre colonne
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)

            LazyVStack(alignment: .leading, spacing: 8) {

                // Placeholder si vide
                if tasks.isEmpty {

                    Text("Déposer ici")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(
                            width: cardSize.width,
                            height: UIConstants.cardHeight
                        )

                } else {

                    // Liste des tâches
                    ForEach(tasks) { task in
                        TaskCardView(task: task) {
                            selectedTaskId = task.id
                        }
                        .frame(width: cardSize.width)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        // Highlight pendant drag
                        isTargeted
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.05)
                    )
            )
            // Zone de drop des tâches
            .dropDestination(for: DraggableTask.self) { items, _ in
                Task { await handleDrop(items) }
                return true
            } isTargeted: { isTargeted = $0 }
        }
        .frame(width: cardSize.width)
        // Animation lors update tâches
        .animation(.easeInOut(duration: 0.25), value: tasks)
    }

    // Gestion du drop
    private func handleDrop(_ items: [DraggableTask]) async {
        guard let item = items.first else { return }

        // Mise à jour UI immédiate
        await MainActor.run {
            tasksVM.moveTask(taskId: item.id, to: status)
        }

        do {
            // Sync backend
            _ = try await TaskService.shared.updateTaskStatus(
                taskId: item.id,
                status: status
            )

            // Notification refresh global
            NotificationCenter.default.post(
                name: .taskDidChange,
                object: nil
            )

        } catch {
            if AppConfig.version == .dev {
                print("Drop updateTaskStatus ERROR:", error)
            }
        }
    }
}
