//
//  ProjectsRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 06/02/2026.
//

import SwiftUI

struct ProjectsRowView: View {
    let project: ProjectResponse
    let isOwner: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)

                Text(project.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(
                        project.membersCount == 1
                        ? "1 membre"
                        : "\(project.membersCount) membres"
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                    
                }
            }

            Spacer()

            
            VStack {
                if isOwner {
                    Label("Owner", systemImage: "crown.fill")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                }
                
                statusBadge
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(project.status.color)
                .frame(width: 8, height: 8)

            Text(project.status.label)
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(project.status.color.opacity(0.15))
        .cornerRadius(8)
    }
}

