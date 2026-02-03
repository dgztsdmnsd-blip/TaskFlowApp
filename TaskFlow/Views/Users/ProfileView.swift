//
//  ProfileView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Vue affichant le profil utilisateur.
//  Elle est présentée en sheet depuis MainView
//  et consomme un ProfileViewModel injecté.
//

import SwiftUI

@MainActor
struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    @StateObject private var vm: ProfileViewModel
    @State private var showEditProfile = false

    init(viewModel: ProfileViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView(ecran: .users)
                Form {
                    if let profile = vm.profile {
                        
                        // Identité
                        Section("Identité") {
                            profileRow("Prénom", profile.firstName)
                            profileRow("Nom", profile.lastName)
                            profileRow("Email", profile.email)
                        }
                        
                        // Compte
                        Section("Compte") {
                            profileRow(
                                "Profil",
                                profile.profil == "MGR" ? "Manager" : "Utilisateur"
                            )
                            
                            profileRow(
                                "Statut",
                                profile.status == "ACTIVE" ? "Actif" : "Inactif"
                            )
                        }
                        
                        // Dates
                        Section("Dates") {
                            profileRow("Création", profile.creationDateFormatted)
                            /* TODO: création d'un profil Admin
                             profileRow(
                             "Sortie",
                             profile.exitDate ?? "-"
                             )*/
                        }
                        
                        // Actions
                        Section("Actions") {
                            
                            BoutonImageView(
                                title: "Modifier mon profil",
                                systemImage: "pencil",
                                style: .primary
                            ) {
                                showEditProfile = true
                            }
                            
                            BoutonImageView(
                                title: "Se déconnecter",
                                systemImage: "arrow.backward.square",
                                style: .danger
                            ) {
                                handleLogout()
                            }
                        }
                    }
                }
                .listSectionSpacing(.compact)
                .navigationTitle("Mon profil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.app.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                if let profile = vm.profile {
                    RegisterView(
                        mode: .edit(profile: profile),
                        profileViewModel: vm
                    )
                    .environmentObject(appState)
                }
            }
        }
    }

    // UI Helpers
    private func profileRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
        }
        .profileRowStyle()
    }
    
    // Logout
    private func handleLogout() {
        SessionManager.shared.logout()
        dismiss()
        appState.flow = .loginHome
    }
}


extension View {
    func profileRowStyle() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel.preview)
}
