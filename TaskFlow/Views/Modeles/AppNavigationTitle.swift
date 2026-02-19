//
//  AppNavigationTitle.swift
//  TaskFlow
//
//  Created by luc banchetti on 19/02/2026.
//

import SwiftUI

struct AppNavigationTitle: ViewModifier {

    let title: String
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.black)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
    }
}
