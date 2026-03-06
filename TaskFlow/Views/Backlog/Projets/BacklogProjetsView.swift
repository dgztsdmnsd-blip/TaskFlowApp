//
//  BacklogProjetsView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Carte projet dans le Backlog.
//  Affiche :
//  - Infos projet
//  - Membres
//  - Colonnes User Stories
//  - Action création US
//

import SwiftUI

struct BacklogProjetsView: View {

    // Projet affiché
    let project: ProjectResponse

    // Indique si l’utilisateur est owner
    let isOwner: Bool

    // Stories filtrées par tag (optionnel)
    let filteredStories: [StoryResponse]?

    // Session utilisateur globale
    @EnvironmentObject private var sessionVM: SessionViewModel

    // Présentation écran création User Story
    @State private var showCreateStory = false

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            // Header Projet
            Text(project.title)
                .font(.headline)
                .adaptiveTextColor()

            // Badge Owner
            if isOwner {
                Label("Owner", systemImage: "crown.fill")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }

            // Section Membres
            VStack(alignment: .leading, spacing: 6) {

                // Nombre de membres
                Text(
                    project.membersCount == 1
                    ? "1 membre"
                    : "\(project.membersCount) membres"
                )
                .font(.footnote)
                .adaptiveTextColor()

                // Liste horizontale des membres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        OwnerBadgeView(member: project.owner)

                        ForEach(project.members) { member in
                            MemberBadgeView(member: member)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Spacer()

            // Colonnes User Stories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {

                    UserStoryColumnView(
                        projectId: project.id,
                        title: "À faire",
                        statut: .notStarted,
                        owner: isOwner,
                        filteredStories: filteredStories
                    )

                    UserStoryColumnView(
                        projectId: project.id,
                        title: "En cours",
                        statut: .inProgress,
                        owner: isOwner,
                        filteredStories: filteredStories
                    )

                    UserStoryColumnView(
                        projectId: project.id,
                        title: "Terminé",
                        statut: .finished,
                        owner: isOwner,
                        filteredStories: filteredStories
                    )
                }
                .padding(.horizontal, 4)
            }

            // Action Création US
            HStack {
                BoutonImageView(
                    title: "Ajouter une user story",
                    systemImage: "list.bullet.rectangle",
                    style: .secondary,
                    action: {
                        showCreateStory = true
                    },
                    accessibilityId: "add.userstory"
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        // Debug Lifecycle
        .logLifecycle("BacklogProjetsView")
        // Background Carte
        .background(BackgroundView(ecran: .projets))
        // Style Carte
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red.opacity(0.5), lineWidth: 0.5)
        )
        // Création User Story
        .fullScreenCover(isPresented: $showCreateStory) {

            if let user = sessionVM.currentUser {

                UserStoryFormView(
                    project: project,
                    owner: ProfileLiteResponse(
                        id: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName
                    ),
                    onCreated: {

                        // Notifie le backlog
                        NotificationCenter.default.post(
                            name: .userStoryDidChange,
                            object: nil
                        )
                    }
                )
            }
        }
    }
}
