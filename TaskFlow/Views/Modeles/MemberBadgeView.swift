//
//  MemberBadgeView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/02/2026.
//

import SwiftUI

struct MemberBadgeView: View {
    
    let member: ProfileLiteResponse
    
    var body: some View {
        HStack(spacing: 4) {
            
            Text(member.lastName.prefix(1).capitalized)
                .font(.caption2)
            
            Text(member.firstName)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.25))
        .clipShape(Capsule())
    }
}
