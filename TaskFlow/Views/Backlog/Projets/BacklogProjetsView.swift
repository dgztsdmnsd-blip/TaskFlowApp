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
    let filteredStories: [StoryResponse]?
    
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

            VStack(alignment: .leading, spacing: 6) {
                
                Text(
                    project.membersCount == 1
                    ? "1 membre"
                    : "\(project.membersCount) membres"
                )
                .font(.footnote)
                .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 6) {
                        // OWNER
                        ownerBadge(project.owner)
                        
                        if !project.members.isEmpty {
                            // MEMBERS
                            ForEach(project.members) { member in
                                memberBadge(member)
                            }
                        }
                    }
                }
            }

            Spacer()

            // User Stories
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


            // Bouton création
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
        .padding()
        .logLifecycle("BacklogProjetsView")
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
                UserStoryFormView(
                    project: project,
                    owner: ProfileLiteResponse(
                        id: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName
                    ),
                    onCreated: {
                        NotificationCenter.default.post(
                            name: .userStoryDidChange,
                            object: nil
                        )
                    }
                )
            }
        }

    }
    
    
    private func memberBadge(_ member: ProfileLiteResponse) -> some View {
        Text(member.firstName)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.25))
            .clipShape(Capsule())
    }
    
    private func ownerBadge(_ member: ProfileLiteResponse) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))
            
            Text(member.firstName)
                .font(.caption2.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.2))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }


}
