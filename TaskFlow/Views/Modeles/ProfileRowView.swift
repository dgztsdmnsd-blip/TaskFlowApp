//
//  ProfileRow.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

// Ligne utilisateur
func profileRow(user: ProfileResponse, isOwner: Bool) -> some View {
    
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                .font(.caption)

            Text(user.email)
                .font(.footnote)
                .foregroundColor(.secondary)
        }

        Spacer()
        
        // OWNER
        if isOwner {
            Label("Owner", systemImage: "crown.fill")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(8)
        }

        Text(user.profil == "MGR" ? "Manager" : "Utilisateur")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                user.profil == "MGR"
                    ? Color.blue.opacity(0.2)
                    : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                user.profil == "MGR" ? .blue : .gray
            )
            .cornerRadius(8)
    }
    .padding(.vertical, 4)
}
