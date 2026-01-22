//
//  BackgroundView.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.75, green: 0.65, blue: 0.95), // violet clair
                Color(red: 0.55, green: 0.80, blue: 0.95)  // bleu ciel
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
