//
//  ProfileRow.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//
//  Ligne représentant un utilisateur dans une liste
//  (nom, email, rôle, badge owner).
//

import SwiftUI

struct ProfileRowView: View {

    // Utilisateur affiché
    let user: ProfileResponse
    
    // Indique si c’est le propriétaire (owner)
    let isOwner: Bool

    var body: some View {
        HStack {

            // Infos principales (nom + email)
            VStack(alignment: .leading, spacing: 4) {
                
                // Nom complet
                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                    .font(.subheadline)

                // Email
                Text(user.email)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Badge OWNER (si applicable)
            if isOwner {
                Label("Owner", systemImage: "crown.fill")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }

            // Badge ROLE
            Text(user.profil == "MGR" ? "Manager" : "Utilisateur")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                // Couleur de fond selon rôle
                .background(
                    user.profil == "MGR"
                        ? Color.blue.opacity(0.2)
                        : Color.gray.opacity(0.2)
                )
                
                // Couleur du texte selon rôle
                .foregroundColor(
                    user.profil == "MGR" ? .blue : .gray
                )
                
                .cornerRadius(8)
        }

        // Espacement vertical de la ligne
        .padding(.vertical, 4)
    }
}
