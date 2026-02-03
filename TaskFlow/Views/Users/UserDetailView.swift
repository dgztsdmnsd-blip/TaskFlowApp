//
//  UserDetailView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//

import SwiftUI

struct UserDetailView: View {

    // Inputs
    let currentUser: ProfileResponse

    // State
    @StateObject private var vm: UserAdminViewModel
    @State private var showConfirmStatus = false
    @State private var showConfirmRole = false

    // Init
    init(currentUser: ProfileResponse, user: ProfileResponse) {
        self.currentUser = currentUser
        _vm = StateObject(wrappedValue: UserAdminViewModel(user: user))
    }

    // Body
    var body: some View {
        ZStack {
            BackgroundView(ecran: .users)
            Form {
                // Identité
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("\(vm.user.firstName.capitalized) \(vm.user.lastName.capitalized)")
                            .font(.title3.bold())
                        
                        Text(vm.user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Rôle & statut
                Section("Profil") {
                    HStack(spacing: 12) {
                        roleBadge
                        statusBadge
                    }
                    .padding(.vertical, 4)
                }
                
                // Dates
                Section("Dates") {
                    infoRow(label: "Création", value: vm.user.creationDateFormatted)
                    //infoRow(label: "Sortie", value: vm.user.exitDateFormatted)
                }
                
                // Actions (Manager uniquement)
                if currentUser.profil == "MGR" {
                    Section("Actions") {
                        
                        // Activer / Désactiver
                        BoutonImageView(
                            title: vm.isActive ? "Désactiver le compte" : "Réactiver le compte",
                            systemImage: vm.isActive ? "person.slash" : "person.check",
                            style: vm.isActive ? .danger : .primary
                        ) {
                            showConfirmStatus = true
                        }
                        .confirmationDialog(
                            vm.isActive ? "Désactiver ce compte ?" : "Réactiver ce compte ?",
                            isPresented: $showConfirmStatus
                        ) {
                            Button(
                                vm.isActive ? "Désactiver" : "Réactiver",
                                role: vm.isActive ? .destructive : .none
                            ) {
                                Task { await vm.toggleStatus() }
                            }
                            
                            Button("Annuler", role: .cancel) {}
                        }
                        
                        // Changer le rôle
                        BoutonImageView(
                            title: vm.isManager ? "Passer en utilisateur" : "Passer en manager",
                            systemImage: "arrow.triangle.2.circlepath",
                            style: .primary
                        ) {
                            showConfirmRole = true
                        }
                        .disabled(vm.isLoading)
                        .confirmationDialog(
                            vm.isManager
                            ? "Passer cet utilisateur en utilisateur ?"
                            : "Passer cet utilisateur en manager ?",
                            isPresented: $showConfirmRole
                        ) {
                            Button("Confirmer") {
                                Task { await vm.toggleRole() }
                            }
                            
                            Button("Annuler", role: .cancel) {}
                        }
                        
                        // Attribuer un projet
                        BoutonImageView(
                            title: "Attribuer un projet",
                            systemImage: "folder.badge.plus",
                            style: .primary
                        ) {
                            // TODO: navigation vers sélection de projet
                        }
                    }
                }
            }
        }
        .navigationTitle("Utilisateur")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Badges
    private var roleBadge: some View {
        badge(
            text: vm.isManager ? "Manager" : "Utilisateur",
            color: vm.isManager ? .blue : .gray
        )
    }

    private var statusBadge: some View {
        badge(
            text: vm.isActive ? "Actif" : "Inactif",
            color: vm.isActive ? .green : .orange
        )
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    // Info row
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    NavigationStack {
        UserDetailView(
            currentUser: .preview, 
            user: .preview2
        )
    }
}
