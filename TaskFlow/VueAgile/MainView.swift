//
//  MainView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            TabView {
                Tab("Terminées", systemImage: "checkmark.circle.fill") {
                    BackgroundView()
                }

                Tab("En cours", systemImage: "clock") {
                    BackgroundView()
                }

                Tab("À venir", systemImage: "calendar") {
                    BackgroundView()
                }
            }
            .tabViewStyle(.automatic)
            .tint(.indigo)
        }
    }
}


#Preview {
    MainView()
}
