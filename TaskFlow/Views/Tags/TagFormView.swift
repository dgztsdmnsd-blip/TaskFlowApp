//
//  TagFormView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  Formulaire de création / modification d’un Tag.
//

import SwiftUI

struct TagFormView: View {

    // Permet de fermer la vue (sheet / fullScreenCover)
    @Environment(\.dismiss) private var dismiss

    // ViewModel du formulaire
    @StateObject var viewModel: TagFormViewModel

    // Callbacks
    // Action déclenchée en cas de succès
    var onSuccess: (() -> Void)?

    // Initialisation
    init(mode: TagMode, onSuccess: (() -> Void)? = nil) {
        _viewModel = StateObject(
            wrappedValue: TagFormViewModel(mode: mode)
        )
        self.onSuccess = onSuccess
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // Background
                BackgroundView(ecran: .tags)
                    .ignoresSafeArea()

                // Formulaire
                Form {

                    // Nom du Tag
                    Section {
                        TextField(
                            "Ex: Urgent, Backend…",
                            text: $viewModel.tagName
                        )
                    } header: {
                        Text("Nom du tag")
                            .adaptiveTextColor()
                    }

                    // Couleur du Tag
                    Section {
                        HStack {

                            ColorPicker(
                                "Choisir une couleur",
                                selection: Binding(
                                    get: {
                                        Color(hex: viewModel.couleur)
                                    },
                                    set: { newColor in
                                        viewModel.couleur =
                                            newColor.toHex() ?? "#FF5733"
                                    }
                                )
                            )

                            Spacer()

                            // Preview couleur
                            Circle()
                                .fill(Color(hex: viewModel.couleur))
                                .frame(width: 26, height: 26)
                        }
                    } header: {
                        Text("Couleur")
                            .adaptiveTextColor()
                    }

                    // Message d’erreur
                    if let error = viewModel.errorMessage {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    // Bouton Enregistrer
                    Section {
                        Button {
                            Task {
                                await viewModel.submit()

                                if viewModel.isSuccess {
                                    onSuccess?()
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()

                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text(
                                        viewModel.isEditing
                                        ? "Mettre à jour"
                                        : "Créer le tag"
                                    )
                                    .bold()
                                }

                                Spacer()
                            }
                        }
                    }
                }
                // Style Form
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                // Navigation Title
                .appNavigationTitle(
                    viewModel.isEditing
                    ? "Modifier Tag"
                    : "Créer Tag"
                )
                // Debug Lifecycle
                .logLifecycle("TagFormView")
                // Toolbar
                .toolbar {

                    // Bouton Annuler
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
