//
//  TagFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//

import Foundation
import Combine

@MainActor
final class TagFormViewModel: ObservableObject {

    let mode: TagMode
    let tag: TagResponse?

    @Published var tagName = ""
    @Published var couleur = ""

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    var isFormValid: Bool {
        !tagName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !couleur.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isEditing: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    init(mode: TagMode, tag: TagResponse? = nil) {
        self.mode = mode
        self.tag = tag

        if case .edit(let tag) = mode {
            tagName = tag.tagName
            couleur = tag.couleur
        }
    }

    func submit() async {
        isLoading = true
        isSuccess = false
        errorMessage = nil
        defer { isLoading = false }

        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            return
        }

        do {
            switch mode {
            case .create:
                _ = try await TagsService.shared.createTag(
                    tagName: tagName,
                    couleur: couleur
                )

            case .edit(let tag):
                _ = try await TagsService.shared.updateTagColor(
                    tagId: tag.id,
                    couleur: couleur
                )

            case .liste:
                break
            }

            isSuccess = true

        } catch {
            errorMessage = "Erreur réseau ou validation."
        }
    }
}
