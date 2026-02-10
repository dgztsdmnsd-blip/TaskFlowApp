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

    let onCreated: () -> Void

    init(
        story: StoryResponse,
        onCreated: @escaping () -> Void
    ) {
        self.onCreated = onCreated
        _vm = StateObject(
            wrappedValue:TaskFormViewModel(
                mode: .create,
                userStory: story
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {

                // Informations principales
                Section(header: Text("Tâches de la user story")) {

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
                            .frame(minHeight: 100)
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

                HStack {

                    Spacer()

                    BoutonImageView(
                        title: "Enregistrer",
                        systemImage: "folder.badge.plus",
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

                    Spacer()
                }
            }
            .navigationTitle("Création de la tâche")
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
