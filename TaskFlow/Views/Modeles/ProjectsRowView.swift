//
//  ProjectsRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//
//  Ligne représentant un projet dans une liste
//

import SwiftUI

struct ProjectsRowView: View {

    // Projet affiché
    let project: ProjectResponse
    
    // Indique si l’utilisateur courant est owner
    let isOwner: Bool

    var body: some View {
        HStack {

            // Infos principales du projet
            VStack(alignment: .leading, spacing: 6) {

                // Titre du projet
                Text(project.title)
                    .font(.headline)

                // Description
                Text(project.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                // Nombre de membres
                Text(
                    project.membersCount == 1
                    ? "1 membre"
                    : "\(project.membersCount) membres"
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()

            // Zone droite (owner + statut)
            VStack {

                // Badge OWNER (si applicable)
                if isOwner {
                    Label("Owner", systemImage: "crown.fill")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                }

                // Badge statut du projet
                statusBadge
            }
        }

        // Espacement vertical de la ligne
        .padding(.vertical, 4)
    }

    // Badge affichant le statut du projet
    private var statusBadge: some View {
        HStack(spacing: 6) {

            // Pastille couleur du statut
            Circle()
                .fill(project.status.color)
                .frame(width: 8, height: 8)

            // Label du statut
            Text(project.status.label)
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        
        // Fond léger teinté
        .background(project.status.color.opacity(0.15))
        
        .cornerRadius(8)
    }
}
