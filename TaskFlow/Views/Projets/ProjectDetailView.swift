//
//  ProjectDetailView.swift
//  TaskFlow
//
//  Écran affichant les détails d’un projet.
//  Permet de consulter les informations, le statut,
//  et les membres. Le propriétaire peut modifier,
//  gérer ou supprimer le projet.
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

// Vue de détail d’un projet
struct ProjectDetailView: View {

    // Session utilisateur (utilisateur courant)
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // ViewModel contenant les données du projet
    @StateObject var vm: ProjectDetailViewModel

    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss
    
    // États d’affichage UI
    @State private var showEdit = false
    @State private var showMembers = false
    @State private var showDeleteAlert = false
    
    // Titre du bouton de changement de statut
    private var nextStatusTitle: String {
        switch vm.project.status {
        case .notStarted: return "Démarrer"
        case .inProgress: return "Terminer"
        case .finished:   return "Réouvrir"
        }
    }

    // Statut cible après action
    private var nextStatus: ProjectStatus {
        switch vm.project.status {
        case .notStarted: return .inProgress
        case .inProgress: return .finished
        case .finished:   return .inProgress
        }
    }

    // Icône du bouton de statut
    private var statusActionIcon: String {
        switch vm.project.status {
        case .notStarted: return "play.circle.fill"
        case .inProgress: return "checkmark.circle.fill"
        case .finished:   return "arrow.counterclockwise.circle"
        }
    }

    var body: some View {
        ZStack {
            
            // Fond personnalisé
            BackgroundView(ecran: .projets)
                .ignoresSafeArea()

            Form {
                
                // Informations principales du projet
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(vm.project.title)
                            .font(.title2.bold())
                        
                        Text(vm.project.description)
                            .foregroundColor(.secondary)
                    }
                } header : {
                    Text("Projet")
                        .adaptiveTextColor()
                }

                // Statut et membres
                Section {
                    VStack(spacing: 16) {
                        statusBadge
                        membersBadge
                        
                        // Liste horizontale des membres
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                OwnerBadgeView(member: vm.project.owner)

                                ForEach(vm.project.members) { member in
                                    MemberBadgeView(member: member)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header : {
                    Text("Statut")
                        .adaptiveTextColor()
                }

                // Actions visibles uniquement pour le propriétaire
                if vm.project.owner.id == sessionVM.currentUser?.id {

                    Section {
                        VStack(spacing: 12) {

                            // Changer le statut du projet
                            BoutonImageView(
                                title: nextStatusTitle,
                                systemImage: statusActionIcon,
                                style: .primary,
                                action: {
                                    Task { await vm.updateStatus(to: nextStatus)}
                                },
                                accessibilityId: "project.status"
                            )

                            // Gérer les membres
                            BoutonImageView(
                                title: "Membres",
                                systemImage: "person.3.fill",
                                style: .secondary
                            ) {
                                showMembers = true
                            }
                        }
                    }

                    Section {
                        VStack(spacing: 12) {

                            // Modifier le projet
                            BoutonImageView(
                                title: "Modifier",
                                systemImage: "pencil",
                                style: .secondary,
                                action: {
                                    showEdit = true
                                },
                                accessibilityId: "project.modifier"
                            )

                            // Supprimer uniquement si non démarré
                            if vm.project.status == .notStarted {
                                BoutonImageView(
                                    title: "Supprimer",
                                    systemImage: "trash",
                                    style: .danger
                                ) {
                                    showDeleteAlert = true
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .appNavigationTitle("Détail du projet")
        .logLifecycle("ProjectDetailView")
        // Sheet édition
        .sheet(isPresented: $showEdit) {
            ProjectEditView(
                project: vm.project,
                onSaved: { Task { await vm.reload() } }
            )
        }
        // Sheet membres
        .sheet(isPresented: $showMembers) {
            NavigationStack {
                ProjectUsersView(project: vm.project)
            }
        }
        // Mise à jour Projet
        .onReceive(NotificationCenter.default.publisher(for: .projectDidChange)) { _ in
            Task {
                await vm.reload()
            }
        }
        // Alerte suppression
        .alert("Supprimer le projet ?", isPresented: $showDeleteAlert) {
            Button("Supprimer", role: .destructive) {
                Task {
                    try? await ProjectService.shared.deleteProject(id: vm.project.id)
                    dismiss()
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est définitive.")
        }
    }
    
    // Badge affichant le statut du projet
    private var statusBadge: some View {
        HStack {
            Text(vm.project.status.label)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(vm.project.status.color.opacity(0.2))
                .foregroundColor(vm.project.status.color)
                .cornerRadius(10)
            
            Spacer()
        }
    }
    
    // Badge affichant le nombre de membres et le rôle owner
    private var membersBadge: some View {
        HStack {
            Label(
                "\(vm.project.membersCount) membres",
                systemImage: "person.2.fill"
            )
            .font(.caption)
            .foregroundColor(.secondary)
            
            Spacer()
            
            if vm.project.owner.id == sessionVM.currentUser?.id {
                Label("Owner", systemImage: "crown.fill")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }
        }
    }
}
