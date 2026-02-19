//
//  BacklogUSView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct BacklogUSView: View {
    let story: StoryResponse
    let isFiltering: Bool
    
    @EnvironmentObject private var sessionVM: SessionViewModel
    @State private var showDetail = false
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isOwner: Bool {
            sessionVM.currentUser?.id == story.owner.id
        }

    var body: some View {
        let cardSize = UIConstants.cardSize(for: sizeClass)
        
        HStack(alignment: .top, spacing: 12) {

            // Barre de couleur (owner)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: story.couleur))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {

                Text(story.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                
                tagsView
                
                Text("\(story.owner.lastName.capitalized) \(story.owner.firstName.capitalized)")
                    .font(.caption)
                    .foregroundColor(.black)
                
                ProgressTaskView(progression: story.progress)


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
                
                if let dueAt = story.dueAt?.toDateOnly() {

                    Label {
                        Text(dueAt, formatter: Self.dateFormatter)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption2)
                    .foregroundColor(.black)
                }
                
                Text(story.description)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(
            width: cardSize.width,
            height: cardSize.height
        )
        .logLifecycle("BacklogUSView")
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    BackgroundView.StoryGradient
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .if(!isFiltering) { view in
            view.draggable(DraggableStory(id: story.id))
        }
        // Tap = consultation
        .onTapGesture {
            showDetail = true
        }

        // Détail / édition
        .fullScreenCover(isPresented: $showDetail) {
            UserStoryDetailView(
                story: story,
                mode: isOwner ? .edit : .readOnly
            )
        }

    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
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
    
    func deleteTag(_ tag: TagResponse) {
        Task {
            do {
                try await TagsService.shared.detachTag(
                    tagId: tag.id,
                    fromStory: story.id
                )

                NotificationCenter.default.post(
                    name: .userStoryDidChange,
                    object: nil
                )

            } catch {
                print("Detach tag error:", error)
            }
        }
    }


}
