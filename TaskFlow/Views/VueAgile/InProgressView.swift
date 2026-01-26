//
//  InProgressView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Vue représentant la section "En cours".
//

import SwiftUI

struct InProgressView: View {
    var body: some View {
        ZStack {
            BackgroundView(ecran: .enCours)
            VStack {
                
                Spacer()
            }
        }
    }
}

#Preview {
    InProgressView()
}
