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
            ZStack {
                BackgroundView(ecran: .projets)
                    .ignoresSafeArea()
                
                Form {
                    
                    // -----------------
                    // Titre
                    // -----------------
                    Section {
                        TextField("Titre du projet", text: $vm.titre)
                            .textInputAutocapitalization(.sentences)
                    } header : {
                        Text("Titre")
                            .foregroundStyle(.black)
                    }
                    
                    // -----------------
                    // Description
                    // -----------------
                    Section {
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 120)
                    } header : {
                        Text("Description")
                            .foregroundStyle(.black)
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
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .appNavigationTitle("Création de projet")
                .logLifecycle("ProjectCreationView")
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
}

#Preview {
    ProjectCreationView(
        viewModel: ProjectFormViewModel(mode: .create)
    )
}
