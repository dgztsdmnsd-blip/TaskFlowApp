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

                        HStack(spacing: 16) {

                            if let priority = story.priority {
                                Label("Priorité P\(priority)", systemImage: "exclamationmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }

                            if let points = story.storyPoint {
                                Label("\(points) pts", systemImage: "speedometer")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }

                            if let dueAt = story.dueAt?.toDateOnly() {
                                Label {
                                    Text(dueAt, style: .date)
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )

                    // Description
                    VStack(alignment: .leading, spacing: 8) {

                        Label("Description", systemImage: "text.alignleft")
                            .font(.headline)

                        Text(story.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                    
                    // Tâches
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

                        ForEach(tasksVM.tasks) { task in
                            TaskRowView(task: task)
                                .swipeActions {
                                    if story.owner.id == session.currentUser?.id {
                                        Button(role: .destructive) {
                                            Task {
                                                try? await TaskService.shared.deleteTask(taskId: task.id)
                                                tasksVM.removeTask(id: task.id)
                                            }
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    }
                                }
                        }

                        if story.owner.id == session.currentUser?.id {
                            BoutonImageView(
                                title: "Ajouter une tâche",
                                systemImage: "checklist",
                                style: .secondary
                            ) {
                                showCreateTask = true
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )

                    
                    Spacer()
                    
                    if story.owner.id == session.currentUser?.id {
                        VStack {
                            BoutonImageView(
                                title: "Modifier",
                                systemImage: "pencil",
                                style: .secondary
                            ) {
                                showCreateTask = true
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            BoutonImageView(
                                title: "Supprimer",
                                systemImage: "trash",
                                style: .danger
                            ) {
                                showDeleteAlert = true
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                                
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                            )
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
                            // TODO: afficher une erreur (toast / alert)
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
