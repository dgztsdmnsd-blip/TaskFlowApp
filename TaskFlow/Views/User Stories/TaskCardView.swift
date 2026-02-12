//
//  TaskRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import SwiftUI

struct TaskRowView: View {

    let task: TaskListResponse
    let onTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(task.status.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .lineLimit(1)  

                if let points = task.storyPoint {
                    Text("\(points) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(task.status.label)
                .font(.caption2)
                .foregroundColor(task.status.color)
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
        .draggable(DraggableTask(id: task.id))

    }
}
