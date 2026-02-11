//
//  TaskFormView.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import SwiftUI

struct TaskFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: TaskFormViewModel

    // INIT CREATION
    init(story: StoryResponse) {
        _vm = StateObject(
            wrappedValue: TaskFormViewModel(
                mode: .create,
                userStory: story
            )
        )
    }

    // INIT EDITION
    init(task: TaskResponse) {
        _vm = StateObject(
            wrappedValue: TaskFormViewModel(
                mode: .edit(task: task),
                userStory: task.userStory
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {

                // Infos principales
                Section(header: Text("Tâche")) {

                    TextField("Titre", text: $vm.titre)
                        .textInputAutocapitalization(.sentences)

                    ZStack(alignment: .topLeading) {
                        if vm.description.isEmpty {
                            Text("Description de la tâche")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $vm.description)
                            .frame(minHeight: 100)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3))
                    )
                    .padding(.vertical, 4)
                }

                // Planification
                Section(header: Text("Planification")) {

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

                // Type
                Section(header: Text("Type")) {

                    ZStack(alignment: .topLeading) {
                        if vm.type.isEmpty {
                            Text("Type de la tâche")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $vm.type)
                            .frame(minHeight: 80)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3))
                    )
                    .padding(.vertical, 4)
                }

                // Erreur
                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // Bouton Save
                HStack {
                    Spacer()

                    BoutonImageView(
                        title: "Enregistrer",
                        systemImage: "checkmark.circle.fill",
                        style: .secondary
                    ) {
                        submit()
                    }
                    .disabled(!vm.isFormValid)

                    Spacer()
                }
            }
            .navigationTitle(vm.isEditing ? "Modifier la tâche" : "Nouvelle tâche")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}


private extension TaskFormView {

    func submit() {
        Task {
            await vm.submit()

            if vm.isSuccess {

                // Notifie toute l’app
                NotificationCenter.default.post(
                    name: .taskDidChange,
                    object: nil
                )

                dismiss()
            }
        }
    }
}
