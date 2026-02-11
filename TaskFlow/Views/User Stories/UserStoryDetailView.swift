//
//  UserStoryDetailView.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import SwiftUI

struct UserStoryDetailView: View {

    let story: StoryResponse
    let mode: UserStoryDetailMode
    let onDeleted: () -> Void
    
    
    
    @State private var showCreateTask = false
    @State private var showDeleteAlert = false
    
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var tasksVM: UserStoryTasksViewModel

    @Environment(\.dismiss) private var dismiss
    
    init(
        story: StoryResponse,
        mode: UserStoryDetailMode,
        onDeleted: @escaping () -> Void
    ) {
        self.story = story
        self.mode = mode
        self.onDeleted = onDeleted
        _tasksVM = StateObject(
            wrappedValue: UserStoryTasksViewModel(userStoryId: story.id)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {

                        HStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: story.couleur))
                                .frame(width: 6)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(story.title)
                                    .font(.title3.bold())

                                Text("\(story.owner.lastName.capitalized) \(story.owner.firstName.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyleView()

                    
                    // Statut
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Label("Statut", systemImage: "flag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(story.status.label)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(story.status.color.opacity(0.15))
                            .foregroundColor(story.status.color)
                            .clipShape(Capsule())
                        
                        Label("Progression", systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)

                        ProgressTaskView(progression: story.progress ?? 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyleView()

                    
                    // Métadonnées (Priorité / Points / Date)
                    HStack(spacing: 20) {

                        if let priority = story.priority {
                            Label("P\(priority)", systemImage: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                        }

                        if let points = story.storyPoint {
                            Label("\(points)", systemImage: "speedometer")
                                .foregroundColor(.blue)
                        }

                        if let dueAt = story.dueAt?.toDateOnly() {
                            Label {
                                Text(dueAt, style: .date)
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .font(.caption)
                    .cardStyleView()

                    // Description
                    VStack(alignment: .leading, spacing: 8) {

                        Label("Description", systemImage: "text.alignleft")
                            .font(.headline)

                        Text(story.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(minHeight: 120)
                    .cardStyleView()

                    // Tâches
                    TasksSectionView(
                        story: story,
                        tasksVM: tasksVM,
                        onAddTask: {
                            showCreateTask = true
                        },
                        onDeleteTask: { taskId in
                            tasksVM.removeTask(id: taskId)
                        }
                    )

                    Spacer()

                    // Actions
                    if story.owner.id == session.currentUser?.id {
                        VStack(spacing: 12) {

                            BoutonImageView(
                                title: "Modifier",
                                systemImage: "pencil",
                                style: .secondary
                            ) {
                                showCreateTask = true
                            }

                            BoutonImageView(
                                title: "Supprimer",
                                systemImage: "trash",
                                style: .danger
                            ) {
                                showDeleteAlert = true
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyleView()
                    }
                }
                .padding()
                     
            }
            .background(
                BackgroundView(ecran: .projets)
            )
            .navigationTitle("User Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert("Supprimer la user story ?", isPresented: $showDeleteAlert) {
                Button("Supprimer", role: .destructive) {
                    Task {
                        do {
                            try await StoriesService.shared.deleteStory(
                                userStoryId: story.id
                            )
                            onDeleted()
                            dismiss()
                        } catch {
                            print("Erreur suppression US:", error)
                        }
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action est définitive.")
            }
        }
        .fullScreenCover(isPresented: $showCreateTask) {
            TaskFormView(
                story: story,
                onCreated: {
                    Task {
                        await tasksVM.loadTasks()
                    }
                }
            )
        }
        .task {
            await tasksVM.loadTasks()
        }

    }
}
