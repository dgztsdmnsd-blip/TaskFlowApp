//
//  TagPickerView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagPickerView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TagPickerViewModel()

    var onTagSelected: (TagResponse) -> Void

    @State private var showCreateTag = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Chargement des tags...")
                }
                else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)

                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                else {
                    List {

                        // Bouton création inline (UX ++)
                        Button {
                            showCreateTag = true
                        } label: {
                            Label("Créer un nouveau tag", systemImage: "plus.circle.fill")
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
            .navigationTitle("Sélectionner un tag")
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

            // Sheet création
            .sheet(isPresented: $showCreateTag) {
                NavigationStack {
                    TagFormView(mode: .create) {

                        // Fermer la sheet
                        showCreateTag = false

                        // Recharger les tags
                        Task {
                            await viewModel.loadTags()
                        }
                    }
                }
            }
        }
    }
}
