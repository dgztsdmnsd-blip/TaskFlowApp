//
//  ProjectFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import Foundation
import Combine

@MainActor
final class ProjectFormViewModel: ObservableObject {

    let mode: ProjectMode

    @Published var titre = ""
    @Published var description = ""

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    init(mode: ProjectMode) {
        self.mode = mode

        if case .edit(let projet) = mode {
            titre = projet.title
            description = projet.description
        }
    }

    func submit() async {
        isLoading = true
        errorMessage = nil

        guard !titre.isEmpty else {
            errorMessage = "Veuillez renseigner le titre."
            isLoading = false
            return
        }

        guard !description.isEmpty else {
            errorMessage = "Veuillez renseigner la description."
            isLoading = false
            return
        }

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
                _ = try await ProjectService.shared.createProject(
                    title: titre,
                    description: description
                )

            case .edit(let projet):
                _ = try await ProjectService.shared.updateProject(
                    id: projet.id,
                    title: titre,
                    description: description
                )

            default:
                break
            }

            isSuccess = true

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur de validation."

        } catch {
            errorMessage = "Erreur réseau. Veuillez réessayer."
        }

        isLoading = false
    }
}
