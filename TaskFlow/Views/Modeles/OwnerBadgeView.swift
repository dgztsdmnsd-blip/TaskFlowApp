//
//  OwnerBadgeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/02/2026.
//

import SwiftUI

struct OwnerBadgeView: View {
    
    let member: ProfileLiteResponse
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))

            // Initiale du nom
            Text(member.lastName.prefix(1).capitalized)
                .font(.caption2)
                        
            // Prénom
            Text(member.firstName)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.2))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }
}
