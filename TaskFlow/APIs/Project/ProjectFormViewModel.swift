//
//  ProjectViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import Foundation
import Combine

enum ProjectMode {
    case create
    case edit(projet: ProjectResponse)
    case liste
}

@MainActor
final class ProjectViewModel: ObservableObject {

    // Mode
    let mode: ProjectMode

    var isCreateMode: Bool {
        if case .create = mode { return true }
        return false
    }

    // Inputs
    @Published var titre = ""
    @Published var description = ""

    // State
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    init(mode: ProjectMode) {
        self.mode = mode
    }

    // Submit
    func submit() async {

        errorMessage = nil

        if mode != .liste {
            guard !titre.isEmpty else {
                errorMessage = "Veuillez renseigner le titre du projet."
                return
            }
            
            guard !description.isEmpty else {
                errorMessage = "Veuillez renseigner une description pour le projet."
                return
            }
        }

        isLoading = true

        do {
            switch mode {

            case .create:
                _ = try await ProjectService.shared.createProject(
                    title: titre,
                    description: description
                )

            case .edit(let projet):
                // TODO: update project
                print("Edition projet \(projet.id)")
            
            case .liste:
                print("Liste des projet")
            
                _ = try await ProjectService.shared.fetchProjects()
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
