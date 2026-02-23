//
//  TagFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//
//  ViewModel gérant la logique du formulaire de tag.
//  Supporte :
//  - Création d’un tag
//  - Modification d’un tag existant
//  - Validation et gestion des états UI

//

import Foundation
import Combine

// ViewModel du formulaire de tag
@MainActor
final class TagFormViewModel: ObservableObject {

    // Mode du formulaire (create / edit)
    let mode: TagMode
    
    // Tag en cours d’édition (si applicable)
    let tag: TagResponse?

    // Champs du formulaire
    @Published var tagName = ""
    @Published var couleur = "#000000"

    // États UI
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    // Validation du formulaire
    var isFormValid: Bool {
        !tagName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !couleur.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Indique si le formulaire est en mode édition
    var isEditing: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    init(mode: TagMode, tag: TagResponse? = nil) {
        self.mode = mode
        self.tag = tag

        // Pré-remplissage en mode édition
        if case .edit(let tag) = mode {
            tagName = tag.tagName
            couleur = tag.couleur
        }
    }

    // Soumet le formulaire (création / mise à jour)
    func submit() async {
        isLoading = true
        isSuccess = false
        errorMessage = nil
        defer { isLoading = false }

        // Validation locale
        guard isFormValid else {
            errorMessage = "Veuillez remplir le nom du tag."
            return
        }

        do {
            switch mode {

            case .create:
                // Création d’un nouveau tag
                _ = try await TagsService.shared.createTag(
                    tagName: tagName,
                    couleur: couleur
                )

            case .edit(let tag):
                // Mise à jour de la couleur du tag
                _ = try await TagsService.shared.updateTagColor(
                    tagId: tag.id,
                    couleur: couleur
                )

            case .liste:
                // Non utilisé ici
                break
            }

            // Succès
            isSuccess = true

        } catch APIError.httpError(_, let message) {

            // Message Symfony / backend
            errorMessage = message ?? "Erreur serveur"

        } catch APIError.decodingError {

            // Backend réponse invalide
            errorMessage = "Réponse serveur invalide"

        } catch {

            // Réseau pur (offline / timeout)
            errorMessage = "Erreur réseau"
        }
    }
}
