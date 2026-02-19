//
//  TaskRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import SwiftUI

struct TaskCardView: View {

    let task: TaskListResponse
    let onTap: (() -> Void)?

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {

        let cardSize = UIConstants.cardSize(for: sizeClass)

        HStack(alignment: .top, spacing: 12) {

            Circle()
                .fill(task.status.color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {

                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

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
        .padding(10)
        .frame(
            width: cardSize.width,
            height: 60
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BackgroundView.tasksGradient.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05))
        )
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
        .draggable(DraggableTask(id: task.id))
    }
}
