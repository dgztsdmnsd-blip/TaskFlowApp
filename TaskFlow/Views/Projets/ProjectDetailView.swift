//
//  ProjectDetailView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

struct ProjectDetailView: View {

    // ViewModel
    @StateObject var vm: ProjectDetailViewModel

    // UI State
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    // Body
    var body: some View {
        ZStack {
            BackgroundView(ecran: .projets)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // -----------------
                    // Header
                    // -----------------
                    VStack(alignment: .leading, spacing: 8) {
                        Text(vm.project.title)
                            .font(.title2.bold())
                        
                        Text(vm.project.description)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // -----------------
                    // Infos
                    // -----------------
                    HStack(spacing: 16) {
                        statusBadge
                        membersBadge
                    }
                    
                    Divider()
                    
                    // -----------------
                    // Actions
                    // -----------------
                    VStack(spacing: 12) {
                        
                        BoutonImageView(
                            title: "Modifier le projet",
                            systemImage: "pencil",
                            style: .primary
                        ) {
                            showEdit = true
                        }
                        
                        // Suppression uniquement si projet non démarré
                        if vm.project.status == .notStarted {
                            BoutonImageView(
                                title: "Supprimer le projet",
                                systemImage: "trash",
                                style: .danger
                            ) {
                                showDeleteAlert = true
                            }
                        }
                    }
                }
                .padding()
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
            
            //TODO: Affectation/retrait de membres
        }
    }

    // Badges
    private var statusBadge: some View {
        Text(vm.project.status.label)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(vm.project.status.color.opacity(0.2))
            .foregroundColor(vm.project.status.color)
            .cornerRadius(10)
    }

    private var membersBadge: some View {
        Label(
            "\(vm.project.membersCount) membres",
            systemImage: "person.2.fill"
        )
        .font(.caption)
        .foregroundColor(.secondary)
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
