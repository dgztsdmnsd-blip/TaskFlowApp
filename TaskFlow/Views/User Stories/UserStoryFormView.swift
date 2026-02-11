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
            Form {

                Section(header: Text("User story")) {

                    TextField("Titre", text: $vm.titre)

                    TextEditor(text: $vm.description)
                        .frame(minHeight: 100)
                }

                Section(header: Text("Planification")) {

                    TextField(
                        "Date (YYYY-MM-DD)",
                        text: Binding(
                            get: { vm.dueAt ?? "" },
                            set: { vm.dueAt = $0.isEmpty ? nil : $0 }
                        )
                    )

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
                }

                Section(header: Text("Couleur")) {
                    ColorPicker(
                        "Couleur",
                        selection: Binding(
                            get: { Color(hex: vm.couleur) },
                            set: { vm.couleur = $0.toHex() ?? "#FF5733" }
                        )
                    )
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                BoutonImageView(
                    title: "Enregistrer",
                    systemImage: vm.isEditMode ? "square.and.pencil" : "folder.badge.plus",
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
            .navigationTitle(vm.isEditMode ? "Modification" : "Création")
        }
    }
}
