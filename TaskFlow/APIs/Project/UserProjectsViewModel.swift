//
//  UserProjectsViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//
//  ViewModel gérant les projets associés
//  à un utilisateur spécifique.
//  Supporte :
//  - Chargement des projets utilisateur
//  - Attribution d’un projet
//  - Gestion loading / erreurs
//

import Foundation
import Combine

// ViewModel des projets d’un utilisateur
@MainActor
final class UserProjectsViewModel: ObservableObject {

    // Liste des projets
    @Published var projects: [ProjectResponse] = []
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    // Identifiant utilisateur
    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    // Charge les projets de l’utilisateur
    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        if AppConfig.version == .dev {
            print("UserProjects → fetchProjects user:", userId)
        }

        do {
            projects = try await ProjectService.shared
                .listProjectsForUser(for: userId)

        } catch APIError.httpError(_, let message) {
            errorMessage = message

        } catch {
            if AppConfig.version == .dev {
                print("fetchProjects ERROR:", error.localizedDescription)
            }
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    // Attribue un projet à l’utilisateur
    func assignProjectToUser(projectId: Int) async {
        errorMessage = nil

        if AppConfig.version == .dev {
            print("Assign Project → project:", projectId, "to user:", userId)
        }

        do {
            try await ProjectService.shared.addMember(
                projectId: projectId,
                userId: userId
            )

            // Rafraîchit la liste après attribution
            await fetchProjects()

        } catch {
            errorMessage = "Impossible d’attribuer le projet."
        }
    }
}
