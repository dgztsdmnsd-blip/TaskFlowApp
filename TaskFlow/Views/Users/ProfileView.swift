//
//  ProfileView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Vue affichant le profil utilisateur.
//  Elle est présentée en sheet depuis MainView.
//

import SwiftUI

@MainActor
struct ProfileView: View {

    // Session utilisateur (authentification / user courant)
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // État global de navigation
    @EnvironmentObject private var appState: AppState
    
    // Permet de fermer la sheet
    @Environment(\.dismiss) private var dismiss

    // Contrôle l’ouverture de l’écran d’édition
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {

                // Fond dégradé écran Users
                BackgroundView(ecran: .users)
                    .ignoresSafeArea()

                Form {
                    
                    // Si utilisateur chargé
                    if let profile = sessionVM.currentUser {
                        
                        // Section Identité
                        Section {
                            profileRow("Prénom", profile.firstName)
                            profileRow("Nom", profile.lastName)
                            profileRow("Email", profile.email)
                        } header : {
                            Text("Identité")
                                .adaptiveTextColor()
                        }
                        
                        // Section Compte
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
                                .adaptiveTextColor()
                        }
                        
                        // Section Dates
                        Section {
                            profileRow(
                                "Création",
                                profile.creationDateFormatted
                            )
                        } header : {
                            Text("Dates")
                                .adaptiveTextColor()
                        }
                        
                        // Section Actions
                        Section {
                            
                            // Bouton édition profil
                            BoutonImageView(
                                title: "Modifier mon profil",
                                systemImage: "pencil",
                                style: .primary,
                                action: {
                                    showEditProfile = true
                                },
                                accessibilityId: "profile.modifier"
                            )
                            
                            // Bouton logout
                            BoutonImageView(
                                title: "Se déconnecter",
                                systemImage: "arrow.backward.square",
                                style: .danger,
                                action: {
                                    handleLogout()
                                },
                                accessibilityId: "profile.deconnexion"
                            )
                        } header : {
                            Text("Actions")
                                .adaptiveTextColor()
                        }
                        
                    } else {
                        
                        // Chargement profil
                        ProgressView("Chargement du profil…")
                    }
                }
                // Titre navigation custom
                .appNavigationTitle("Mon profil")
                // Bouton fermeture sheet
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
            // Cache le fond gris du Form
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            // Debug lifecycle
            .logLifecycle("ProfileView")
            // Écran édition profil
            .fullScreenCover(isPresented: $showEditProfile) {
                if let profile = sessionVM.currentUser {
                    NavigationStack {
                        RegisterView(mode: .edit(profile: profile))
                    }
                }
            }
        }
    }

    // Ligne label / valeur
    private func profileRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {

            // Label discret
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)

            // Valeur principale
            Text(value)
                .font(.subheadline)
        }
    }

    // Déconnexion utilisateur
    private func handleLogout() {
        
        // Reset session
        sessionVM.logout()
        
        // Ferme la vue profil
        dismiss()
        
        // Retour écran login
        appState.flow = .loginHome
    }
}
