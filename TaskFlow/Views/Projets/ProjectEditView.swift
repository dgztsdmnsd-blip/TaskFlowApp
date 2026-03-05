//
//  ProjectEditView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  Écran permettant de modifier un projet existant.
//  L’utilisateur peut mettre à jour le titre et la description.
//  La vue gère les états de chargement, succès et erreur.
//

import SwiftUI

// Vue d’édition d’un projet
struct ProjectEditView: View {

    // Permet de fermer la vue
    @Environment(\.dismiss) private var dismiss
    
    // ViewModel du formulaire (mode édition)
    @StateObject private var vm: ProjectFormViewModel

    // Callback optionnel appelé après sauvegarde réussie
    let onSaved: (() -> Void)?

    // Initialisation avec le projet à éditer
    init(project: ProjectResponse, onSaved: (() -> Void)? = nil) {
        _vm = StateObject(
            wrappedValue: ProjectFormViewModel(mode: .edit(projet: project))
        )
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                // Fond personnalisé
                BackgroundView(ecran: .projets)
                    .ignoresSafeArea()
                
                Form {
                    
                    // Champ titre
                    Section {
                        TextField("Titre du projet", text: $vm.titre)
                    } header : {
                        Text("Titre")
                            .adaptiveTextColor()
                    }
                    
                    // Champ description
                    Section {
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 120)
                    } header : {
                        Text("Description")
                            .adaptiveTextColor()
                    }
                    
                    // Affichage d’erreur éventuelle
                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Bouton sauvegarde
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
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .appNavigationTitle("Modifier le projet")
                .logLifecycle("ProjectEditView")
                // Bouton fermer
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fermer") { dismiss() }
                            .accessibilityIdentifier("project.mod.close")
                    }
                }
                // Réagit au succès de sauvegarde
                .onChange(of: vm.isSuccess) { _, success in
                    guard success else { return }
                    onSaved?()
                    dismiss()
                }
            }
        }
    }
}
