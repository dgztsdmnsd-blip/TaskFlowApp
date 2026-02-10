//
//  UserStoryView.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

struct UserStoryView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: UserStoryFormViewModel

    init(project: ProjectResponse, owner: ProfileLiteResponse) {
        _vm = StateObject(
            wrappedValue: UserStoryFormViewModel(
                mode: .create,
                project: project,
                owner: owner
            )
        )
    }

    // Body
    var body: some View {
        NavigationStack {
            Form {
                
                // Informations principales
                Section(header: Text("User story")) {
                    
                    TextField("Titre", text: $vm.titre)
                        .textInputAutocapitalization(.sentences)
                    
                    ZStack(alignment: .topLeading) {
                        if vm.description.isEmpty {
                            Text("Description de la user story")
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
                    
                    TextField(
                        "Date de livraison (YYYY-MM-DD)",
                        text: Binding(
                            get: { vm.dueAt ?? "" },
                            set: { vm.dueAt = $0.isEmpty ? nil : $0 }
                        )
                    )
                    .keyboardType(.numbersAndPunctuation)
                    
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
                
                // Couleur
                Section(header: Text("Couleur")) {
                    
                    ColorPicker(
                        "Couleur de la user story",
                        selection: Binding(
                            get: { Color(hex: vm.couleur) },
                            set: { vm.couleur = $0.toHex() ?? "#FF5733" }
                        )
                    )
                }
                
                //  Erreur
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
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.isFormValid)
                    
                    Spacer()
                }
                
            }
            .navigationTitle("Création d'une user story")
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

