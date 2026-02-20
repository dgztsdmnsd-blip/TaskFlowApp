//
//  BacklogUSView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Carte User Story dans le Backlog.
//  Affiche :
//  - Infos principales
//  - Tags
//  - Progression
//  - Métadonnées (priorité, points, échéance)
//

import SwiftUI

struct BacklogUSView: View {

    // Inputs
    let story: StoryResponse
    let isFiltering: Bool

    // Environment
    @EnvironmentObject private var sessionVM: SessionViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.colorScheme) private var scheme

    // State (UI)
    @State private var showDetail = false

    // Vérifie si l’utilisateur est owner de la story
    private var isOwner: Bool {
        sessionVM.currentUser?.id == story.owner.id
    }

    var body: some View {

        // Taille adaptative (iPhone / iPad)
        let cardSize = UIConstants.cardSize(for: sizeClass)

        HStack(alignment: .top, spacing: 12) {

            // Barre couleur (identité visuelle)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: story.couleur))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {

                // Titre
                Text(story.title)
                    .font(.headline)
                    .lineLimit(1)
                    .adaptiveTextColor()

                // Tags
                tagsView

                // Owner
                Text("\(story.owner.lastName.capitalized) \(story.owner.firstName.capitalized)")
                    .font(.caption)
                    .adaptiveTextColor()

                // Progression
                ProgressTaskView(progression: story.progress)

                // Métadonnées
                HStack(spacing: 12) {

                    if let priority = story.priority {
                        Text("P\(priority)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if let points = story.storyPoint {
                        Label("\(points)", systemImage: "speedometer")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                // Échéance
                if let dueAt = story.dueAt?.toDateOnly() {
                    Label {
                        Text(dueAt, formatter: Self.dateFormatter)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption2)
                    .adaptiveTextColor()
                }

                // Description
                Text(story.description)
                    .font(.subheadline)
                    .adaptiveTextColor()
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(
            width: cardSize.width,
            height: cardSize.height
        )
        // Debug Lifecycle
        .logLifecycle("BacklogUSView")
        // Background Carte
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BackgroundView.storyGradient(for: scheme))
        )
        // Style Carte
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        // Drag & Drop
        .if(!isFiltering) { view in
            view.draggable(DraggableStory(id: story.id))
        }
        // Interaction
        .onTapGesture {
            showDetail = true
        }
        // Détail / Édition
        .fullScreenCover(isPresented: $showDetail) {
            UserStoryDetailView(
                story: story,
                mode: isOwner ? .edit : .readOnly
            )
        }
    }

    // Date Formatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()

    // Tags View
    var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(story.tags) { tag in
                    TagBadgeMiniView(tag: tag) {
                        deleteTag(tag)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // Détache un tag de la User Story
    func deleteTag(_ tag: TagResponse) {
        Task {
            do {
                try await TagsService.shared.detachTag(
                    tagId: tag.id,
                    fromStory: story.id
                )

                // Rafraîchit le backlog
                NotificationCenter.default.post(
                    name: .userStoryDidChange,
                    object: nil
                )

            } catch {
                if AppConfig.version == .dev {
                    print("Detach tag error:", error)
                }
            }
        }
    }
}
