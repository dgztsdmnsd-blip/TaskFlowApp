//
//  ProjectCreationView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

struct ProjectCreationView: View {

    // Dependencies
    @StateObject private var vm: ProjectFormViewModel
    let onCreated: () -> Void

    // UI
    @Environment(\.dismiss) private var dismiss

    // Init
    init(
        viewModel: ProjectFormViewModel,
        onCreated: @escaping () -> Void = {}
    ) {
        _vm = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    // Body
    var body: some View {
        NavigationStack {
            Form {

                // -----------------
                // Titre
                // -----------------
                Section("Titre") {
                    TextField("Titre du projet", text: $vm.titre)
                        .textInputAutocapitalization(.sentences)
                }

                // -----------------
                // Description
                // -----------------
                Section("Description") {
                    TextEditor(text: $vm.description)
                        .frame(minHeight: 120)
                }

                // -----------------
                // Action
                // -----------------
                Section {
                    BoutonImageView(
                        title: "Créer le projet",
                        systemImage: "folder.badge.plus",
                        style: .primary
                    ) {
                        Task {
                            await vm.submit()
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
            .onChange(of: vm.isSuccess) {
                if vm.isSuccess {
                    onCreated()
                    dismiss()
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
        viewModel: ProjectFormViewModel(mode: .create)
    )
}
