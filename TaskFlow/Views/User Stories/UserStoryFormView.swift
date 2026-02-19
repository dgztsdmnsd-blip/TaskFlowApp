//
//  UserStoryFormView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct UserStoryFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: UserStoryFormViewModel

    let onCreated: () -> Void

    // CREATE
    init(
        project: ProjectResponse,
        owner: ProfileLiteResponse,
        onCreated: @escaping () -> Void
    ) {
        self.onCreated = onCreated
        _vm = StateObject(
            wrappedValue: UserStoryFormViewModel(
                mode: .create,
                project: project,
                owner: owner
            )
        )
    }

    // EDIT
    init(
        story: StoryResponse,
        onCreated: @escaping () -> Void
    ) {
        self.onCreated = onCreated
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
                BackgroundView(ecran: .stories)
                    .ignoresSafeArea()

                Form {

                    // -------------------------
                    // User Story
                    // -------------------------
                    Section {

                        TextField("Titre", text: $vm.titre)

                        TextEditor(text: $vm.description)
                            .frame(minHeight: 100)
                    } header : {
                        Text("User story")
                            .foregroundStyle(.black)
                    }

                    // -------------------------
                    // Planification
                    // -------------------------
                    Section {

                        Toggle(
                            "Définir une échéance",
                            isOn: Binding(
                                get: { vm.dueDate != nil },
                                set: { isOn in
                                    vm.dueDate = isOn ? (vm.dueDate ?? Date()) : nil
                                }
                            )
                        )

                        if vm.dueDate != nil {
                            DatePicker(
                                "Date d’échéance",
                                selection: Binding(
                                    get: { vm.dueDate ?? Date() },
                                    set: { vm.dueDate = $0 }
                                ),
                                in: Date()..., // empêche dates passées
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }

                        Stepper(
                            value: Binding(
                                get: { vm.priority ?? 1 },
                                set: { vm.priority = $0 }
                            ),
                            in: 1...10
                        ) {
                            Text("Priorité : \(vm.priority ?? 1)")
                        }

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
                            .foregroundStyle(.black)
                    }

                    // -------------------------
                    // Couleur
                    // -------------------------
                    Section {

                        ColorPicker(
                            "Couleur",
                            selection: Binding(
                                get: { Color(hex: vm.couleur) },
                                set: { vm.couleur = $0.toHex() ?? "#FF5733" }
                            )
                        )
                    } header : {
                        Text("Couleur")
                            .foregroundStyle(.black)
                    }

                    // -------------------------
                    // Erreur
                    // -------------------------
                    if let error = vm.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }

                    // -------------------------
                    // Action
                    // -------------------------
                    BoutonImageView(
                        title: "Enregistrer",
                        systemImage: vm.isEditMode
                        ? "square.and.pencil"
                        : "folder.badge.plus",
                        style: .secondary
                    ) {
                        Task {
                            await vm.submit()

                            if vm.isSuccess {
                                onCreated()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.isFormValid)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .appNavigationTitle(vm.isEditMode ? "Modification" : "Création")
            .logLifecycle("UserStoryFormView")
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
