//
//  UserStoryDetailView.swift
//  TaskFlow
//
//  Écran de détail d’une User Story.
//  Permet :
//  - Visualisation complète
//  - Édition (si owner)
//  - Gestion des tâches
//  - Gestion des tags
//

import SwiftUI

struct UserStoryDetailView: View {

    // Story d’origine
    let story: StoryResponse
    
    // Mode (readOnly / edit)
    let mode: UserStoryDetailMode

    // Story affichée (rafraîchie depuis API)
    @State private var currentStory: StoryResponse
    
    // Affichage édition story
    @State private var showEditStory = false
    
    // Affichage création tâche
    @State private var showCreateTask = false
    
    // Alert suppression
    @State private var showDeleteAlert = false
    
    // Sélecteur tags
    @State private var showTagPicker = false

    // Session utilisateur
    @EnvironmentObject private var session: SessionViewModel
    
    // ViewModel tâches
    @StateObject private var tasksVM: UserStoryTasksViewModel
    
    // Dismiss view
    @Environment(\.dismiss) private var dismiss
    
    // Adaptation iPad / iPhone
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    // Titre du bouton de changement de statut
    private var nextStatusTitle: String {
        switch currentStory.status {
        case .notStarted: return "Démarrer"
        case .inProgress: return "Terminer"
        case .finished:   return "Réouvrir"
        }
    }

    // Statut cible après action
    private var nextStatus: StoryStatus {
        switch currentStory.status {
        case .notStarted: return .inProgress
        case .inProgress: return .finished
        case .finished:   return .inProgress
        }
    }

    // Icône du bouton de statut
    private var statusActionIcon: String {
        switch currentStory.status {
        case .notStarted: return "play.circle.fill"
        case .inProgress: return "checkmark.circle.fill"
        case .finished:   return "arrow.counterclockwise.circle"
        }
    }

    // Init
    init(
        story: StoryResponse,
        mode: UserStoryDetailMode
    ) {
        self.story = story
        self.mode = mode
        
        // Initialise la story locale
        _currentStory = State(initialValue: story)

        // Initialise VM tâches
        _tasksVM = StateObject(
            wrappedValue: UserStoryTasksViewModel(userStoryId: story.id)
        )
    }

    // Body
    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(spacing: 20) {

                    header              // Titre + owner
                    tagsSection         // Tags associés
                    statusSection       // Statut + progression
                    metaSection         // Priorité / points / date
                    descriptionSection  // Description
                    tasksSection        // Tâches
                    actionsSection      // Actions owner

                    Spacer()
                }
                .padding()
            }
            .background(BackgroundView(ecran: .stories))
            .appNavigationTitle("User Story")
            // Bouton fermeture
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityIdentifier("us.detail.close")
                }
            }
            // Alert suppression
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
                Task { await refreshAll() }
            }
        ) {
            TaskFormView(story: currentStory)
        }
        // Edition story
        .fullScreenCover(
            isPresented: $showEditStory,
            onDismiss: {
                Task { await refreshAll() }
            }
        ) {
            UserStoryFormView(
                story: currentStory,
                onCreated: { }
            )
        }
        // Sélecteur tags
        .sheet(isPresented: $showTagPicker) {
            TagPickerView { selectedTag in
                showTagPicker = false
                attachTag(selectedTag)
            }
        }
        // Refresh après modif tâche
        .onReceive(NotificationCenter.default.publisher(for: .taskDidChange)) { _ in
            Task { await refreshAll() }
        }
        // Notifie backlog au retour
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
    // HEADER
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {

                // Barre colorée liée à la story
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: currentStory.couleur))
                    .frame(width: 6)

                VStack(alignment: .leading, spacing: 6) {
                    
                    // Titre de la User Story
                    Text(currentStory.title)
                        .font(.title3.bold())

                    // Nom du propriétaire
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
    
    // TAGS
    var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                
                // Titre section
                Label("Tags", systemImage: "tag.fill")
                    .font(.headline)

                Spacer()

                // Bouton ajout tag
                Button {
                    showTagPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityIdentifier("us.tag.ajouter")
            }

            // Aucun tag
            if currentStory.tags.isEmpty {
                Text("Aucun tag associé")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // Liste des tags
            else {
                FlowLayout(spacing: 8) {
                    ForEach(currentStory.tags) { tag in
                        
                        // Badge tag + suppression
                        TagBadgeView(tag: tag) {
                            removeTag(tag)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .logLifecycle("UserStoryDetailView")
        .cardStyleView()
    }

    // STATUT & PROGRESSION
    var statusSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Label statut
            Label("Statut", systemImage: "flag")
                .font(.caption)
                .foregroundColor(.secondary)

            // Badge statut
            Text(currentStory.status.label)
                .font(.subheadline.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(currentStory.status.color.opacity(0.15))
                .foregroundColor(currentStory.status.color)
                .clipShape(Capsule())

            // Label progression
            Label("Progression", systemImage: "chart.bar.fill")
                .font(.caption)
                .foregroundColor(.secondary)

            // Barre de progression
            ProgressTaskView(progression: currentStory.progress)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    // MÉTADONNÉES
    var metaSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Planification", systemImage: "timer")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                
                // Priorité
                if let priority = currentStory.priority {
                    Label("P\(priority)", systemImage: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                }
                
                // Story points
                if let points = currentStory.storyPoint {
                    Label("\(points)", systemImage: "speedometer")
                        .foregroundColor(.blue)
                }
                
                // Date échéance formatée
                if let dueAtString = currentStory.dueAt,
                   let dueDate = dueAtString.toDateOnly() {
                    
                    Label {
                        Text(dueDate, style: .date)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                // Calendrier pour la date d'échéance
                else if currentStory.dueAt != nil {
                    
                    Label(currentStory.dueAt!, systemImage: "calendar")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .font(.caption)
        .cardStyleView()
    }

    // DESCRIPTION
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Titre section
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)

            // Texte description
            Text(currentStory.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyleView()
    }

    // TACHES
    var tasksSection: some View {
        TasksSectionView(
            story: currentStory,
            tasksVM: tasksVM,
            
            // Action ajout tâche
            onAddTask: { showCreateTask = true },
            
            // Action suppression tâche
            onDeleteTask: { taskId in
                tasksVM.removeTask(id: taskId)
            }
        )
    }

    // ACTIONS OWNER
    var actionsSection: some View {
        Group {
            if currentStory.owner.id == session.currentUser?.id {
                VStack(spacing: 12) {

                    // Changer le statut
                    BoutonImageView(
                        title: nextStatusTitle,
                        systemImage: statusActionIcon,
                        style: .primary
                    ) {
                        updateUserStoryStatus(to: nextStatus)
                    }
                    
                    // Bouton édition
                    BoutonImageView(
                        title: "Modifier",
                        systemImage: "pencil",
                        style: .secondary
                    ) {
                        showEditStory = true
                    }

                    // Bouton suppression
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
    
    // TAGS
    // Attache un tag à la story
    func attachTag(_ tag: TagResponse) {
        Task {
            do {
                _ = try await TagsService.shared.attachTag(
                    tagId: tag.id,
                    toStory: currentStory.id
                )

                // Refresh UI
                await refreshAll()

            } catch {
                if AppConfig.version == .dev {
                    print("Attach tag error:", error)
                }
            }
        }
    }
    
    // Détache un tag de la story
    func removeTag(_ tag: TagResponse) {
        Task {
            do {
                try await TagsService.shared.detachTag(
                    tagId: tag.id,
                    fromStory: currentStory.id
                )

                // Refresh UI
                await refreshAll()

            } catch {
                if AppConfig.version == .dev {
                    print("Detach tag error:", error)
                }
            }
        }
    }
}


private extension UserStoryDetailView {
    // Recharge complètement la User Story + ses tâches
    func refreshAll() async {
        do {
            // Récupération de la story à jour depuis l’API
            currentStory = try await StoriesService.shared.fetchUserStory(
                userStoryId: story.id
            )
            
            // Rechargement des tâches par statut
            await tasksVM.loadTasksByStatus()
            
        } catch {
            // Log erreur réseau / backend
            if AppConfig.version == .dev {
                print("Refresh error:", error)
            }
        }
    }
    
    // Supprime la User Story courante
    func deleteStory() {
        Task {
            do {
                // Appel API suppression
                try await StoriesService.shared.deleteStory(
                    userStoryId: currentStory.id
                )
                
                // Notifie le backlog / listes
                NotificationCenter.default.post(
                    name: .userStoryDidChange,
                    object: nil
                )
                
                // Ferme l’écran détail
                dismiss()
                
            } catch {
                // Log erreur suppression
                if AppConfig.version == .dev {
                    print("Delete story error:", error)
                }
            }
        }
    }
    
    // Mise à jour du statut de la user story
    func updateUserStoryStatus (to statut: StoryStatus) {

        Task {
            do {
                _ = try await StoriesService.shared.updateStoryStatus(
                    userStoryId: currentStory.id,
                    status: statut
                )
                
                await refreshAll()

            } catch {
                if AppConfig.version == .dev {
                    print("Erreur changement de statut:", error)
                }
            }
        }
    }
}
