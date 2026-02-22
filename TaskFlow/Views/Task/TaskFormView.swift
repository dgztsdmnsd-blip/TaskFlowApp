//
//  TaskFormView.swift
//  TaskFlow
//
//  Formulaire création / modification tâche
//

import SwiftUI

struct TaskFormView: View {

    // Fermeture de la vue
    @Environment(\.dismiss) private var dismiss
    
    // ViewModel du formulaire
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
            ZStack {

                // Background global
                BackgroundView(ecran: .tasks)
                    .ignoresSafeArea()
                
                Form {
                    
                    // Infos principales
                    Section {
                        
                        // Champ titre
                        TextField("Titre", text: $vm.titre)
                            .textInputAutocapitalization(.sentences)
                        
                        // Champ description avec placeholder
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

                    } header : {
                        Text("Tâche")
                            .adaptiveTextColor()
                    }
                    
                    // Planification
                    Section {
                        
                        // Story points
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
                    
                    // Type
                    Section {
                        
                        // Champ type avec placeholder
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

                    } header : {
                        Text("Type")
                            .adaptiveTextColor()
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
                        
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            // Titre navigation adaptatif
            .appNavigationTitle(
                vm.isEditing
                ? "Modifier la tâche"
                : "Nouvelle tâche"
            )
            // Debug lifecycle
            .logLifecycle("TaskFormView")
            // Bouton fermeture
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

    // Soumission formulaire
    func submit() {
        Task {
            await vm.submit()

            if vm.isSuccess {

                // Notifie toute l’app
                NotificationCenter.default.post(
                    name: .taskDidChange,
                    object: nil
                )

                // Fermeture vue
                dismiss()
            }
        }
    }
}
