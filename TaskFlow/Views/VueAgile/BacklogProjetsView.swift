//
//  BacklogProjetsView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct BacklogProjetsView: View {

    // Inputs
    let project: ProjectResponse
    let isOwner: Bool
    
    // Session
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    // Création US
    @State private var showCreateStory = false

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            // Projet
            Text(project.title)
                .font(.headline)

            if isOwner {
                Label("Owner", systemImage: "crown.fill")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }

            Text(
                project.membersCount == 1
                ? "1 membre"
                : "\(project.membersCount) membres"
            )
            .font(.footnote)
            .foregroundColor(.secondary)

            Spacer()

            // User Stories
            HStack(alignment: .top, spacing: 12) {

                UserStoryColumnView(
                    projectId: project.id,
                    title: "À faire",
                    statut: .notStarted
                )

                UserStoryColumnView(
                    projectId: project.id,
                    title: "En cours",
                    statut: .inProgress
                )

                UserStoryColumnView(
                    projectId: project.id,
                    title: "Terminé",
                    statut: .finished
                )
            }


            // Bouton création
            if isOwner {
                HStack {
                    
                    BoutonImageView(
                        title: "Ajouter une user story",
                        systemImage: "list.bullet.rectangle",
                        style: .secondary
                    ) {
                        showCreateStory = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .background(
            BackgroundView(ecran: .projets)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red.opacity(0.5), lineWidth: 0.5)
        )
        .fullScreenCover(isPresented: $showCreateStory) {
            if let user = sessionVM.currentUser {
                UserStoryView(
                    project: project,
                    owner: ProfileLiteResponse(
                        id: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName
                    )
                )
            }
        }

    }
}
