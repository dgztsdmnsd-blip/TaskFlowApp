//
//  ProjectCreationView.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  Écran permettant à l’utilisateur de créer un nouveau projet.
//  L’utilisateur peut saisir un titre, une description,
//  puis valider via le bouton de création.
//  La vue gère les états de chargement, succès et erreur.
//

import SwiftUI

// Vue permettant de créer un nouveau projet
struct ProjectCreationView: View {

    // ViewModel contenant l’état du formulaire
    @StateObject private var vm: ProjectFormViewModel
    
    // Callback exécuté après la création réussie
    let onCreated: () -> Void

    // Permet de fermer la vue (dismiss)
    @Environment(\.dismiss) private var dismiss

    // Initialisation
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
                
                // Fond personnalisé de l’écran
                BackgroundView(ecran: .projets)
                    .ignoresSafeArea()
                
                // Formulaire principal
                Form {
                    
                    // Section : Titre
                    Section {
                        // Champ de saisie du titre du projet
                        TextField("Titre du projet", text: $vm.titre)
                            .textInputAutocapitalization(.sentences)
                            .accessibilityIdentifier("project.titre")
                    } header : {
                        Text("Titre")
                            .adaptiveTextColor()
                    }
                    
                    // Section : Description
                    Section {
                        // Zone de texte multi-lignes pour la description
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 120)
                            .accessibilityIdentifier("project.texte")
                    } header : {
                        Text("Description")
                            .adaptiveTextColor()
                    }
                    
                    // Section : Action
                    Section {
                        // Bouton de soumission du formulaire
                        BoutonImageView(
                            title: "Créer le projet",
                            systemImage: "folder.badge.plus",
                            style: .primary,
                            action: {
                                Task {
                                    // Appel asynchrone de création
                                    await vm.submit()
                                }
                            },
                            accessibilityId: "project.creation"
                        )
                        // Désactivé pendant le chargement
                        .disabled(vm.isLoading)
                    }
                }
                // Style du formulaire
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                // Titre de navigation
                .appNavigationTitle("Création de projet")
                // Debug / logs cycle de vie
                .logLifecycle("ProjectCreationView")
                // Toolbar (bouton fermer)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Ferme la vue
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityIdentifier("project.close")
                    }
                }
                // Réagit au succès de création
                .onChange(of: vm.isSuccess) {
                    if vm.isSuccess {
                        // Callback externe
                        onCreated()
                        
                        // Fermeture automatique
                        dismiss()
                    }
                }
                // Affichage d’une alerte en cas d’erreur
                .alert("Erreur", isPresented: .constant(vm.errorMessage != nil)) {
                    Button("OK", role: .cancel) {
                        // Reset du message d’erreur
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
