//
//  ProjectCreationView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

struct ProjectCreationView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ProjectViewModel

    init(viewModel: ProjectViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {

                // Titre
                Section("Titre") {
                    TextField("Titre du projet", text: $vm.titre)
                        .textInputAutocapitalization(.sentences)
                }

                // Description
                Section("Description") {
                    TextEditor(text: $vm.description)
                        .frame(minHeight: 120)
                }

                // Actions
                Section {
                    Button {
                        Task {
                            await vm.submit()
                            if vm.isSuccess {
                                dismiss()
                            }
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Label("Créer le projet", systemImage: "pencil")
                        }
                    }
                    .disabled(vm.isLoading)
                }
            }
            .navigationTitle("Création de projet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert("Erreur", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    vm.errorMessage = nil
                }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ProjectCreationView(
        viewModel: ProjectViewModel(mode: .create)
    )
}
