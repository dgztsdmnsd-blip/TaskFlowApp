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
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Titre du projet", text: $vm.titre)
                    } header : {
                        Text("Titre")
                            .foregroundStyle(.black)
                    }
                    
                    Section {
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 120)
                    } header : {
                        Text("Description")
                            .foregroundStyle(.black)
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
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .appNavigationTitle("Modifier le projet")
                .logLifecycle("ProjectEditView")
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

