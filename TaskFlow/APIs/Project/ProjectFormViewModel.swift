//
//  ProjectFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  ViewModel gérant la logique du formulaire projet.
//  Supporte :
//  - Création de projet
//  - Édition de projet existant
//  - Validation locale
//  - Gestion loading / succès / erreur

//

import Foundation
import Combine

// ViewModel du formulaire projet
@MainActor
final class ProjectFormViewModel: ObservableObject {

    // Mode du formulaire (create / edit)
    let mode: ProjectMode

    // Champs du formulaire
    @Published var titre = ""
    @Published var description = ""

    // États UI
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    init(mode: ProjectMode) {
        self.mode = mode

        // Pré-remplissage en mode édition
        if case .edit(let projet) = mode {
            titre = projet.title
            description = projet.description
        }
    }

    // Validation simple du formulaire
    var isFormValid: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // Soumet le formulaire
    func submit() async {
        isLoading = true
        isSuccess = false
        errorMessage = nil

        // Validation locale
        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs."
            isLoading = false
            return
        }

        // Vérifie modifications en mode édition
        if case .edit(let projet) = mode {
            guard titre != projet.title || description != projet.description else {
                errorMessage = "Aucune modification détectée."
                isLoading = false
                return
            }
        }

        do {
            switch mode {

            case .create:
                // Création projet
                _ = try await ProjectService.shared.createProject(
                    title: titre,
                    description: description
                )

            case .edit(let projet):
                // Mise à jour projet
                _ = try await ProjectService.shared.updateProject(
                    id: projet.id,
                    title: titre,
                    description: description
                )

            case .liste:
                break
            }

            isSuccess = true

        } catch APIError.httpError(_, let message) {
            // Erreur backend
            errorMessage = message ?? "Erreur de validation."

        } catch {
            // Erreur réseau / inconnue
            errorMessage = "Erreur réseau. Veuillez réessayer."
        }

        isLoading = false
    }
}
