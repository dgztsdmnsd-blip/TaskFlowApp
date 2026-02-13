//
//  TagFormView.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import SwiftUI

struct TagFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: TagFormViewModel

    var onSuccess: (() -> Void)?

    init(mode: TagMode, onSuccess: (() -> Void)? = nil) {
        _viewModel = StateObject(
            wrappedValue: TagFormViewModel(mode: mode)
        )
        self.onSuccess = onSuccess
    }

    var body: some View {
        NavigationStack {
            Form {

                // Nom du tag
                Section(header: Text("Nom du tag")) {
                    TextField("Ex: Urgent, Backend…", text: $viewModel.tagName)
                }

                // Couleur
                Section(header: Text("Couleur")) {
                    HStack {

                        ColorPicker(
                            "Choisir une couleur",
                            selection: Binding(
                                get: {
                                    Color(hex: viewModel.couleur)
                                },
                                set: { newColor in
                                    viewModel.couleur = newColor.toHex() ?? "#FF5733"
                                }
                            )
                        )

                        Spacer()

                        // Preview couleur
                        Circle()
                            .fill(Color(hex: viewModel.couleur))
                            .frame(width: 26, height: 26)
                    }
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
                                Text(viewModel.isEditing ? "Mettre à jour" : "Créer le tag")
                                    .bold()
                            }

                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Modifier Tag" : "Créer Tag")
            .toolbar {

                // Annuler
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
