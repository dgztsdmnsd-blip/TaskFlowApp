//
//  ProjectDetailView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

struct ProjectDetailView: View {

    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // ViewModel
    @StateObject var vm: ProjectDetailViewModel

    // UI State
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showMembers = false
    @State private var showDeleteAlert = false
    
    private var nextStatusTitle: String {
        switch vm.project.status {
        case .notStarted: return "Démarrer"
        case .inProgress: return "Terminer"
        case .finished:   return "Réouvrir"
        }
    }

    private var nextStatus: ProjectStatus {
        switch vm.project.status {
        case .notStarted: return .inProgress
        case .inProgress: return .finished
        case .finished:   return .inProgress
        }
    }

    private var statusActionIcon: String {
        switch vm.project.status {
        case .notStarted: return "play.circle.fill"
        case .inProgress: return "checkmark.circle.fill"
        case .finished:   return "arrow.counterclockwise.circle"
        }
    }



    // Body
    var body: some View {
        ZStack {
            BackgroundView(ecran: .projets)
            Form {
                    
                    // -----------------
                    // Header
                    // -----------------
                    Section ("Projet") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(vm.project.title)
                                .font(.title2.bold())
                            
                            Text(vm.project.description)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // -----------------
                    // Infos
                    // -----------------
                    Section ("Statut") {
                        VStack(spacing: 16) {
                            statusBadge
                            membersBadge
                        }
                    }
                    
                    
                    // -----------------
                    // Actions
                    // -----------------
                if vm.project.owner.id == sessionVM.currentUser?.id {
                        Section {
                            VStack(spacing: 12) {
                                
                                // Progression de l'état
                                BoutonImageView(
                                    title: nextStatusTitle,
                                    systemImage: statusActionIcon,
                                    style: .primary
                                ) {
                                    Task {
                                        await vm.updateStatus(to: nextStatus)
                                    }
                                }
                                
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
                                BoutonImageView(
                                    title: "Modifier",
                                    systemImage: "pencil",
                                    style: .secondary
                                ) {
                                    showEdit = true
                                }
                                
                                // Suppression uniquement si projet non démarré
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
            }
            .navigationTitle("Détail du projet")
            .navigationBarTitleDisplayMode(.inline)
            
            // -----------------
            // EDIT
            // -----------------
            .sheet(isPresented: $showEdit) {
                ProjectEditView(
                    project: vm.project,
                    onSaved: {
                        Task { await vm.reload() }
                    }
                )
            }
        
            // -----------------
            // MEMBERS
            // -----------------
            .sheet(isPresented: $showMembers) {
                NavigationStack {
                    ProjectUsersView(project: vm.project)
                }
            }
            
            // -----------------
            // DELETE
            // -----------------
            .alert("Supprimer le projet ?", isPresented: $showDeleteAlert) {
                Button("Supprimer", role: .destructive) {
                    Task {
                        try? await ProjectService.shared
                            .deleteProject(id: vm.project.id)
                        dismiss()
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action est définitive.")
            }
    }

    // Badges
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

#Preview {
    NavigationStack {
        ProjectDetailView(
            vm: ProjectDetailViewModel(
                project: .previewNotStarted
            )
        )
    }
}
