//
//  TagRowView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagRowView: View {

    let tag: TagResponse

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: tag.couleur))
                .frame(width: 14, height: 14)

            Text(tag.tagName)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
