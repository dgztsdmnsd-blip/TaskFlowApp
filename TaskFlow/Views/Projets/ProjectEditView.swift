//
//  ProjectEditView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

struct ProjectEditView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ProjectFormViewModel

    /// Callback optionnel appelé quand la sauvegarde est OK
    let onSaved: (() -> Void)?

    init(project: ProjectResponse, onSaved: (() -> Void)? = nil) {
        _vm = StateObject(
            wrappedValue: ProjectFormViewModel(mode: .edit(projet: project))
        )
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView(ecran: .projets)
                Form {
                    Section("Titre") {
                        TextField("Titre du projet", text: $vm.titre)
                    }
                    
                    Section("Description") {
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 120)
                    }
                    
                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Section {
                        Section {
                            BoutonImageView(
                                title: "Enregistrer",
                                systemImage: "checkmark",
                                style: .primary
                            ) {
                                Task { await vm.submit() }
                            }
                            .disabled(vm.isLoading)
                        }
                    }
                }
                .navigationTitle("Modifier le projet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fermer") { dismiss() }
                    }
                }
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    onSaved?()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectEditView(project: .previewNotStarted)
    }
}

