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

    @EnvironmentObject private var sessionVM: SessionViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView(ecran: .users)
                    .ignoresSafeArea()

                Form {
                    if let profile = sessionVM.currentUser {

                        Section {
                            profileRow("Prénom", profile.firstName)
                            profileRow("Nom", profile.lastName)
                            profileRow("Email", profile.email)
                        } header : {
                            Text("Identité")
                                .foregroundStyle(.black)
                        }

                        Section {
                            profileRow(
                                "Profil",
                                profile.profil == "MGR" ? "Manager" : "Utilisateur"
                            )
                            profileRow(
                                "Statut",
                                profile.status == "ACTIVE" ? "Actif" : "Inactif"
                            )
                        } header : {
                            Text("Compte")
                                .foregroundStyle(.black)
                        }

                        Section {
                            profileRow(
                                "Création",
                                profile.creationDateFormatted
                            )
                        } header : {
                            Text("Dates")
                                .foregroundStyle(.black)
                        }

                        Section {
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
                        } header : {
                            Text("Actions")
                                .foregroundStyle(.black)
                        }
                    } else {
                        ProgressView("Chargement du profil…")
                    }
                }
                .appNavigationTitle("Mon profil")
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
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .logLifecycle("ProfileView")
            .fullScreenCover(isPresented: $showEditProfile) {
                if let profile = sessionVM.currentUser {
                    NavigationStack {
                        RegisterView(mode: .edit(profile: profile))
                        }
                }
            }
        }
    }

    private func profileRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
        }
    }

    private func handleLogout() {
        
        sessionVM.logout()
        dismiss()
        appState.flow = .loginHome
    }
}
