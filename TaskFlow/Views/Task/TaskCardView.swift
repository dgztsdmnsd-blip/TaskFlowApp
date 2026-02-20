//
//  TaskRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//
//  Carte visuelle représentant une tâche
//

import SwiftUI

struct TaskCardView: View {

    // Tâche affichée
    let task: TaskListResponse
    
    // Action au tap (optionnelle)
    let onTap: (() -> Void)?

    // Environnement UI
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.colorScheme) private var scheme

    var body: some View {

        // Taille adaptative selon device
        let cardSize = UIConstants.cardSize(for: sizeClass)

        HStack(alignment: .top, spacing: 12) {

            // Indicateur statut (couleur)
            Circle()
                .fill(task.status.color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {

                // Titre tâche
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                // Story points (si présent)
                if let points = task.storyPoint {
                    Text("\(points) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Label statut
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
                .fill(
                    // Gradient adaptatif Light/Dark
                    BackgroundView.tasksGradient(for: scheme)
                        .opacity(0.35)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05))
        )
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        // Zone tappable complète
        .contentShape(Rectangle())
        // Interaction tap
        .onTapGesture { onTap?() }
        // Drag & Drop tâche
        .draggable(DraggableTask(id: task.id))
    }
}
