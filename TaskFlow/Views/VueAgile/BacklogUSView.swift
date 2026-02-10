//
//  BacklogUSView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct BacklogUSView: View {
    let story: StoryResponse

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Barre de couleur (owner)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: story.couleur))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {

                Text(story.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(story.owner.lastName.capitalized) \(story.owner.firstName.capitalized)")
                    .font(.caption)
                    .foregroundColor(.black)

                HStack(spacing: 12) {

                    if let priority = story.priority {
                        Label("P\(priority)", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if let points = story.storyPoint {
                        Label("\(points)", systemImage: "speedometer")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    if let dueAt = story.dueAt?.toDateOnly() {
                        Label {
                            Text(dueAt, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
                
                Text(story.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(height: 140)  
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .draggable(
            DraggableStory(id: story.id)
        )
    }
}
