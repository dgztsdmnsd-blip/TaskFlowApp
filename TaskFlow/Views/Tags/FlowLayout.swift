//
//  FlowLayout.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct FlowLayout<Content: View>: View {

    var spacing: CGFloat = 8
    let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)],
            spacing: spacing
        ) {
            content()
        }
    }
}
