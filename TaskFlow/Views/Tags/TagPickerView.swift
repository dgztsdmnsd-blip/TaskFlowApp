//
//  TagPickerView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Écran de sélection d’un tag.
//  Permet :
//  - Choix d’un tag existant
//  - Création rapide d’un nouveau tag
//

import SwiftUI

struct TagPickerView: View {

    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss

    // ViewModel de chargement des tags
    @StateObject private var viewModel = TagPickerViewModel()

    // Callback
    // Action déclenchée lors de la sélection d’un tag
    var onTagSelected: (TagResponse) -> Void

    // Présentation sheet création tag
    @State private var showCreateTag = false

    var body: some View {
        NavigationStack {
            ZStack {

                // Background
                BackgroundView(ecran: .tags)
                    .ignoresSafeArea()

                Group {

                    // Loading State
                    if viewModel.isLoading {
                        ProgressView("Chargement des tags...")

                    // Error State
                    } else if let error = viewModel.errorMessage {

                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)

                            Text(error)
                                .foregroundColor(.red)
                        }

                    // Tags List
                    } else {

                        List {

                            // Création
                            Button {
                                showCreateTag = true
                            } label: {
                                Label(
                                    "Créer un nouveau tag",
                                    systemImage: "plus.circle.fill"
                                )
                                .foregroundColor(.accentColor)
                            }

                            // Liste des tags existants
                            ForEach(viewModel.tags) { tag in
                                Button {
                                    onTagSelected(tag)
                                    dismiss()
                                } label: {
                                    TagRowView(tag: tag)
                                }
                            }
                        }
                    }
                }
                // Style List
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                // Navigation Title
                .appNavigationTitle("Sélectionner un tag")
                // Toolbar
                .toolbar {

                    // Bouton fermeture
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }

                    // Bouton nouveau tag
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showCreateTag = true
                        } label: {
                            Label("Nouveau tag", systemImage: "plus")
                        }
                    }
                }
                // Chargement initial
                .task {
                    await viewModel.loadTags()
                }
                // Debug Lifecycle
                .logLifecycle("TagPickerView")
                // Sheet Création Tag
                .sheet(isPresented: $showCreateTag) {
                    NavigationStack {
                        TagFormView(mode: .create) {

                            // Ferme la sheet
                            showCreateTag = false

                            // Recharge les tags
                            Task {
                                await viewModel.loadTags()
                            }

                            // Notifie le reste de l’app
                            NotificationCenter.default.post(
                                name: .tagsDidChange,
                                object: nil
                            )
                        }
                    }
                }
            }
        }
    }
}
