//
//  UserDetailView.swift
//  TaskFlow
//
//  Created by luc banchetti on 28/01/2026.
//
//  Vue affichant les détails d’un utilisateur
//  (identité, rôle, statut, projets, actions admin).
//

import SwiftUI

struct UserDetailView: View {

    // Utilisateur actuellement connecté
    let currentUser: ProfileResponse


    // ViewModel admin utilisateur
    @StateObject private var vm: UserAdminViewModel
    
    // Dialogues de confirmation
    @State private var showConfirmStatus = false
    @State private var showConfirmRole = false
    
    // Sheet projets utilisateur
    @State private var showUserProjects = false

    // Init
    init(currentUser: ProfileResponse, user: ProfileResponse) {
        self.currentUser = currentUser
        
        // Initialisation ViewModel avec user cible
        _vm = StateObject(
            wrappedValue: UserAdminViewModel(user: user)
        )
    }

    // Body
    var body: some View {
        ZStack {

            // Fond dégradé écran Users
            BackgroundView(ecran: .users)
                .ignoresSafeArea()

            Form {

                // Section Identité
                Section {
                    VStack(alignment: .leading, spacing: 6) {

                        // Nom complet
                        Text("\(vm.user.firstName.capitalized) \(vm.user.lastName.capitalized)")
                            .font(.title3.bold())

                        // Email
                        Text(vm.user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // Section Rôle / Statut
                Section {
                    HStack(spacing: 12) {
                        roleBadge
                        statusBadge
                    }
                    .padding(.vertical, 4)

                } header : {
                    Text("Profil")
                        .adaptiveTextColor()
                }

                // Section Dates
                Section {
                    infoRow(
                        label: "Création",
                        value: vm.user.creationDateFormatted
                    )

                } header : {
                    Text("Dates")
                        .adaptiveTextColor()
                }

                // Section Projets
                Section {

                    // Nombre de projets
                    projectsBadge

                    // Actions visibles seulement pour managers
                    if vm.user.id != currentUser.id {
                        if currentUser.profil == "MGR" {

                            // Attribution projet
                            BoutonImageView(
                                title: "Attribuer un projet",
                                systemImage: "folder.badge.plus",
                                style: .primary
                            ) {
                                showUserProjects = true
                            }
                        }
                    }

                } header : {
                    Text("Projets")
                        .adaptiveTextColor()
                }

                // Section Actions Admin
                if vm.user.id != currentUser.id {
                    if currentUser.profil == "MGR" {

                        Section {

                            // Activer / Désactiver compte
                            BoutonImageView(
                                title: vm.isActive
                                    ? "Désactiver le compte"
                                    : "Réactiver le compte",
                                systemImage: vm.isActive
                                    ? "person.slash"
                                    : "person.check",
                                style: vm.isActive ? .danger : .primary
                            ) {
                                showConfirmStatus = true
                            }
                            .confirmationDialog(
                                vm.isActive
                                    ? "Désactiver ce compte ?"
                                    : "Réactiver ce compte ?",
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

                            // Changement rôle user
                            BoutonImageView(
                                title: vm.isManager
                                    ? "Passer en utilisateur"
                                    : "Passer en manager",
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

                        } header : {
                            Text("Action")
                                .adaptiveTextColor()
                        }
                    }
                }
            }

            // Nettoyage fond Form
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        // Titre navigation custom
        .appNavigationTitle("Utilisateur")
        // Debug lifecycle
        .logLifecycle("UserDetailView")
        // Sheet gestion projets
        .sheet(isPresented: $showUserProjects) {
            NavigationStack {
                UserProjectsView(userId: vm.user.id)
            }
        }
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

    // Info Row
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }

    // Projects Badge
    private var projectsBadge: some View {
        HStack {
            Label(
                "\(vm.user.projectsCount) projets",
                systemImage: "folder.fill"
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}
