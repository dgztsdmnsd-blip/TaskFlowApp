//
//  MainView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

import SwiftUI

struct MainView: View {

    @State private var showProfile = false
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        TabView {

            NavigationStack {
                CompletedView()
                    .navigationTitle("Complétées")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("Terminées", systemImage: "checkmark.circle.fill")
            }

            NavigationStack {
                InProgressView()
                    .navigationTitle("En cours")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("En cours", systemImage: "clock")
            }

            NavigationStack {
                TodoView()
                    .navigationTitle("À venir")
                    .toolbar {
                        profileButton
                    }
            }
            .tabItem {
                Label("À venir", systemImage: "calendar")
            }
        }
        .tint(.indigo)
        .sheet(isPresented: $showProfile) {
            ProfileView(viewModel: profileVM)
        }
    }

    private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
            }
        }
    }
}
