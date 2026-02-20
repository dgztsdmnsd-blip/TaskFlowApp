//
//  UserStoryFormView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Vue gérant la création et modification d'utilisateur
//

import SwiftUI

struct UserStoryFormView: View {

    // Permet de fermer l’écran (sheet / fullScreenCover)
    @Environment(\.dismiss) private var dismiss
    
    // ViewModel du formulaire
    @StateObject private var vm: UserStoryFormViewModel

    // Callback après création / édition réussie
    let onCreated: () -> Void

    // INIT – MODE CREATE
    init(
        project: ProjectResponse,
        owner: ProfileLiteResponse,
        onCreated: @escaping () -> Void
    ) {
        self.onCreated = onCreated
        
        // Initialisation du VM en mode création
        _vm = StateObject(
            wrappedValue: UserStoryFormViewModel(
                mode: .create,
                project: project,
                owner: owner
            )
        )
    }

    // INIT – MODE EDIT
    init(
        story: StoryResponse,
        onCreated: @escaping () -> Void
    ) {
        self.onCreated = onCreated
        
        // Initialisation du VM en mode édition
        _vm = StateObject(
            wrappedValue: UserStoryFormViewModel(
                mode: .edit(story: story),
                project: story.project,
                owner: story.owner
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                // Fond dégradé de l’écran Story
                BackgroundView(ecran: .stories)
                    .ignoresSafeArea()

                Form {

                    // SECTION – Infos Story
                    Section {

                        // Champ titre
                        TextField("Titre", text: $vm.titre)

                        // Champ description
                        TextEditor(text: $vm.description)
                            .frame(minHeight: 100)
                            
                    } header : {
                        Text("User story")
                            .adaptiveTextColor()
                    }

                    // SECTION – Planification
                    Section {

                        // Toggle échéance ON/OFF
                        Toggle(
                            "Définir une échéance",
                            isOn: Binding(
                                get: { vm.dueDate != nil },
                                set: { isOn in
                                    // Active ou retire la date
                                    vm.dueDate = isOn
                                        ? (vm.dueDate ?? Date())
                                        : nil
                                }
                            )
                        )

                        // Sélecteur date si échéance active
                        if vm.dueDate != nil {
                            DatePicker(
                                "Date d’échéance",
                                selection: Binding(
                                    get: { vm.dueDate ?? Date() },
                                    set: { vm.dueDate = $0 }
                                ),
                                in: Date()..., // Empêche dates passées
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }

                        // Sélecteur priorité
                        Stepper(
                            value: Binding(
                                get: { vm.priority ?? 1 },
                                set: { vm.priority = $0 }
                            ),
                            in: 1...10
                        ) {
                            Text("Priorité : \(vm.priority ?? 1)")
                        }

                        // Sélecteur story points
                        Stepper(
                            value: Binding(
                                get: { vm.storyPoint ?? 0 },
                                set: { vm.storyPoint = $0 }
                            ),
                            in: 0...10
                        ) {
                            Text("Story points : \(vm.storyPoint ?? 0)")
                        }
                        
                    } header : {
                        Text("Planification")
                            .adaptiveTextColor()
                    }

                    // SECTION – Couleur
                    Section {

                        // Sélecteur couleur Story
                        ColorPicker(
                            "Couleur",
                            selection: Binding(
                                get: { Color(hex: vm.couleur) },
                                set: { vm.couleur = $0.toHex() ?? "#FF5733" }
                            )
                        )
                        
                    } header : {
                        Text("Couleur")
                            .adaptiveTextColor()
                    }

                    // SECTION – Erreurs
                    if let error = vm.errorMessage {
                        
                        // Message d’erreur VM / API
                        Text(error)
                            .foregroundColor(.red)
                    }

                    // ACTION – Save
                    BoutonImageView(
                        title: "Enregistrer",
                        systemImage: vm.isEditMode
                        ? "square.and.pencil"
                        : "folder.badge.plus",
                        style: .secondary
                    ) {
                        Task {
                            // Soumission formulaire
                            await vm.submit()

                            // Succès → callback + fermeture
                            if vm.isSuccess {
                                onCreated()
                                dismiss()
                            }
                        }
                    }
                    // Désactive bouton si formulaire invalide
                    .disabled(!vm.isFormValid)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
            // Titre dynamique Create / Edit
            .appNavigationTitle(vm.isEditMode ? "Modification" : "Création")
            
            // Debug lifecycle view
            .logLifecycle("UserStoryFormView")
            
            // Bouton Annuler
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
