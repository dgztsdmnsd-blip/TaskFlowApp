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

    @State private var currentStory: StoryResponse
    @State private var showEditStory = false
    @State private var showCreateTask = false
    @State private var showDeleteAlert = false
    @State private var showTagPicker = false

    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var tasksVM: UserStoryTasksViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        story: StoryResponse,
        mode: UserStoryDetailMode
    ) {
        self.story = story
        self.mode = mode
        _currentStory = State(initialValue: story)

        _tasksVM = StateObject(
            wrappedValue: UserStoryTasksViewModel(userStoryId: story.id)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(spacing: 20) {

                    header
                    tagsSection
                    statusSection
                    metaSection
                    descriptionSection
                    tasksSection
                    actionsSection

                    Spacer()
                }
                .padding()
            }
            .background(BackgroundView(ecran: .projets))
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
                    deleteStory()
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Cette action est définitive.")
            }
        }

        // Création tâche
        .fullScreenCover(
            isPresented: $showCreateTask,
            onDismiss: {
                Task {
                    await refreshAll()
                }
            }
        ) {
            TaskFormView(
                story: currentStory
            )
        }


        // Édition story
        .fullScreenCover(isPresented: $showEditStory, onDismiss: {
            Task { await refreshAll() }
        }) {
            UserStoryFormView(
                story: currentStory,
                onCreated: { }
            )
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .taskDidChange)) { _ in
            Task {
                await refreshAll()
            }
        }
        
        // Tags
        .sheet(isPresented: $showTagPicker) {
            TagPickerView { selectedTag in
                showTagPicker = false
                attachTag(selectedTag)
            }
        }

        // Refresh backlog au retour
        .onDisappear {
            NotificationCenter.default.post(
                name: .userStoryDidChange,
                object: nil
            )
        }

        // Chargement initial
        .task {
            await refreshAll()
        }
    }
}


private extension UserStoryDetailView {

    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: currentStory.couleur))
                    .frame(width: 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text(currentStory.title)
                        .font(.title3.bold())

                    Text("\(currentStory.owner.lastName.capitalized) \(currentStory.owner.firstName.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }
    
    var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Label("Tags", systemImage: "tag.fill")
                    .font(.headline)

                Spacer()

                Button {
                    showTagPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }

            if currentStory.tags.isEmpty {
                Text("Aucun tag associé")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(currentStory.tags) { tag in
                        TagBadgeView(tag: tag) {
                            removeTag(tag)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }


    var statusSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Label("Statut", systemImage: "flag")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(currentStory.status.label)
                .font(.subheadline.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(currentStory.status.color.opacity(0.15))
                .foregroundColor(currentStory.status.color)
                .clipShape(Capsule())

            Label("Progression", systemImage: "chart.bar.fill")
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressTaskView(progression: currentStory.progress)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    var metaSection: some View {
        HStack(spacing: 20) {

            if let priority = currentStory.priority {
                Label("P\(priority)", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
            }

            if let points = currentStory.storyPoint {
                Label("\(points)", systemImage: "speedometer")
                    .foregroundColor(.blue)
            }

            if let dueAt = currentStory.dueAt?.toDateOnly() {
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
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Label("Description", systemImage: "text.alignleft")
                .font(.headline)

            Text(currentStory.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    var tasksSection: some View {
        TasksSectionView(
            story: currentStory,
            tasksVM: tasksVM,
            onAddTask: { showCreateTask = true },
            onDeleteTask: { taskId in
                tasksVM.removeTask(id: taskId)
            }
        )
    }

    var actionsSection: some View {
        Group {
            if currentStory.owner.id == session.currentUser?.id {
                VStack(spacing: 12) {

                    BoutonImageView(
                        title: "Modifier",
                        systemImage: "pencil",
                        style: .secondary
                    ) {
                        showEditStory = true
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
    }
    
    func attachTag(_ tag: TagResponse) {
        Task {
            do {
                _ = try await TagsService.shared.attachTag(
                    tagId: tag.id,
                    toStory: currentStory.id
                )

                await refreshAll()

            } catch {
                print("Attach tag error:", error)
            }
        }
    }
    
    func removeTag(_ tag: TagResponse) {
        Task {
            do {
                try await TagsService.shared.detachTag(
                    tagId: tag.id,
                    fromStory: currentStory.id
                )

                await refreshAll()

            } catch {
                print("Detach tag error:", error)
            }
        }
    }


}

private extension UserStoryDetailView {
    
    func refreshAll() async {
        do {
            currentStory = try await StoriesService.shared.fetchUserStory(
                userStoryId: story.id
            )
            
            await tasksVM.loadTasksByStatus()
            
        } catch {
            print("Refresh error:", error)
        }
    }
    
    func deleteStory() {
        Task {
            do {
                try await StoriesService.shared.deleteStory(
                    userStoryId: currentStory.id
                )
                
                NotificationCenter.default.post(
                    name: .userStoryDidChange,
                    object: nil
                )
                
                dismiss()
                
            } catch {
                print("Delete story error:", error)
            }
        }
    }
}
