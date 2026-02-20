//
//  TaskDetailView.swift
//  TaskFlow
//
//  Détail d’une tâche
//

import SwiftUI

struct TaskDetailView: View {

    // Identifiant tâche
    let taskId: Int

    // Données tâche
    @State private var task: TaskResponse?
    
    // États UI
    @State private var isLoading = false
    @State private var showDeleteAlert = false
    @State private var showEditTask = false
    @State private var isUpdatingStatus = false

    // Session utilisateur
    @EnvironmentObject private var session: SessionViewModel
    
    // Fermeture vue
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {

            // Chargement
            if isLoading {
                ProgressView()

            // Contenu tâche
            } else if let task {
                content(task)

            // Erreur chargement
            } else {
                Text("Impossible de charger la tâche.")
                    .foregroundColor(.secondary)
            }
        }
        .appNavigationTitle("Tâche")
        
        // Bouton fermeture
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        
        // Alerte suppression
        .alert("Supprimer la tâche ?", isPresented: $showDeleteAlert) {
            Button("Supprimer", role: .destructive) {
                deleteTask()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Cette action est définitive.")
        }
        // Édition tâche
        .fullScreenCover(isPresented: $showEditTask, onDismiss: {
            Task { await refreshTask() }
        }) {
            if let task {
                TaskFormView(task: task)
            }
        }
        // Notification refresh parent
        .onDisappear {
            NotificationCenter.default.post(
                name: .taskDidChange,
                object: nil
            )
        }
        // Chargement initial
        .task {
            await refreshTask()
        }
    }
}


private extension TaskDetailView {

    // Contenu principal
    @ViewBuilder
    func content(_ task: TaskResponse) -> some View {
        ScrollView {

            VStack(spacing: 20) {

                header(task)
                statusSection(task)
                metaSection(task)
                typeSection(task)
                descriptionSection(task)
                actionsSection(task)

                Spacer()
            }
            .padding()
        }
        .background(BackgroundView(ecran: .tasks))
    }

    // Header tâche
    func header(_ task: TaskResponse) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(task.title)
                    .font(.title3.bold())
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    // Statut tâche
    func statusSection(_ task: TaskResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Label("Statut", systemImage: "flag")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(task.status.label)
                .font(.subheadline.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(task.status.color.opacity(0.15))
                .foregroundColor(task.status.color)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    // Meta infos
    func metaSection(_ task: TaskResponse) -> some View {
        HStack {
            if let points = task.storyPoint {
                Label("\(points)", systemImage: "speedometer")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .font(.caption)
        .cardStyleView()
    }

    // Type tâche
    func typeSection(_ task: TaskResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Label("Type", systemImage: "square.grid.2x2")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(task.type)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    // Description tâche
    func descriptionSection(_ task: TaskResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Label("Description", systemImage: "text.alignleft")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(task.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }
}


private extension TaskDetailView {

    // Boutons d’action (owner uniquement)
    func actionsSection(_ task: TaskResponse) -> some View {
        Group {
            if task.userStory.owner.id == session.currentUser?.id {

                VStack(spacing: 12) {

                    // Avancement statut
                    if task.status != .finished {
                        BoutonImageView(
                            title: buttonTitle(for: task.status),
                            systemImage: buttonIcon(for: task.status),
                            style: .secondary
                        ) {
                            updateStatus(task)
                        }
                        .disabled(isUpdatingStatus)
                    }

                    // Édition
                    BoutonImageView(
                        title: "Modifier",
                        systemImage: "pencil",
                        style: .secondary
                    ) {
                        showEditTask = true
                    }

                    // Suppression
                    BoutonImageView(
                        title: "Supprimer",
                        systemImage: "trash",
                        style: .danger
                    ) {
                        showDeleteAlert = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .logLifecycle("TaskDetailView")
                .cardStyleView()
            }
        }
    }
}


private extension TaskDetailView {

    // Chargement tâche
    func refreshTask() async {
        isLoading = true
        defer { isLoading = false }

        do {
            task = try await TaskService.shared.fetchTask(taskId: taskId)
            if AppConfig.version == .dev {
                print("Task chargée:", task?.title ?? "")
            }
        } catch {
            if AppConfig.version == .dev {
                print("Erreur chargement tâche:", error)
            }
        }
    }

    // Suppression tâche
    func deleteTask() {
        guard let task else { return }

        Task {
            do {
                try await TaskService.shared.deleteTask(taskId: task.id)

                NotificationCenter.default.post(
                    name: .taskDidChange,
                    object: nil
                )

                dismiss()

            } catch {
                if AppConfig.version == .dev {
                    print("Erreur suppression tâche:", error)
                }
            }
        }
    }

    // Mise à jour statut
    func updateStatus(_ task: TaskResponse) {
        guard task.status != .finished else { return }

        isUpdatingStatus = true

        Task {
            defer { isUpdatingStatus = false }

            do {
                let updated = try await TaskService.shared.updateTaskStatus(
                    taskId: task.id,
                    status: task.status.nextStatus
                )

                await MainActor.run {
                    self.task = updated
                }

                NotificationCenter.default.post(
                    name: .taskDidChange,
                    object: nil
                )

            } catch {
                if AppConfig.version == .dev {
                    print("Erreur update status:", error)
                }
            }
        }
    }

    // Titre bouton statut
    func buttonTitle(for status: TaskStatus) -> String {
        switch status {
        case .notStarted: return "Démarrer"
        case .inProgress: return "Terminer"
        case .finished: return "Terminée"
        }
    }

    // Icône bouton statut
    func buttonIcon(for status: TaskStatus) -> String {
        switch status {
        case .notStarted: return "play.fill"
        case .inProgress: return "checkmark.circle.fill"
        case .finished: return "checkmark"
        }
    }
}
