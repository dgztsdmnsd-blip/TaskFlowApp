//
//  TaskColumnView.swift
//  TaskFlow
//

import SwiftUI

struct TaskColumnView: View {

    let title: String
    let status: TaskStatus
    let tasks: [TaskListResponse]
    @ObservedObject var tasksVM: UserStoryTasksViewModel

    @Binding var selectedTaskId: Int?
    @State private var isTargeted = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {

        let cardSize = UIConstants.cardSize(for: sizeClass)

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)

            LazyVStack(alignment: .leading, spacing: 8) {

                if tasks.isEmpty {

                    Text("Déposer ici")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(
                            width: cardSize.width,
                            height: UIConstants.cardHeight
                        )

                } else {

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
                        isTargeted
                        ? Color.accentColor.opacity(0.15)
                        : Color.secondary.opacity(0.05)
                    )
            )
            .dropDestination(for: DraggableTask.self) { items, _ in
                Task { await handleDrop(items) }
                return true
            } isTargeted: { isTargeted = $0 }
        }
        .frame(width: cardSize.width)
        .animation(.easeInOut(duration: 0.25), value: tasks)
    }

    private func handleDrop(_ items: [DraggableTask]) async {
        guard let item = items.first else { return }

        await MainActor.run {
            tasksVM.moveTask(taskId: item.id, to: status)
        }

        do {
            _ = try await TaskService.shared.updateTaskStatus(
                taskId: item.id,
                status: status
            )

            NotificationCenter.default.post(name: .taskDidChange, object: nil)

        } catch {
            print("Drop updateTaskStatus ERROR:", error)
        }
    }
}
