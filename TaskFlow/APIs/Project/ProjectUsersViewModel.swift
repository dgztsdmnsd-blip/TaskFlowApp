//
//  ProjectUsersViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 04/02/2026.
//
//  ViewModel gérant la logique de gestion
//  des membres d’un projet.
//  Supporte :
//  - Chargement des membres
//  - Ajout d’un membre
//  - Suppression d’un membre
//  - Gestion loading / erreurs
//

import Foundation
import Combine

// ViewModel de gestion des membres projet
@MainActor
final class ProjectUsersViewModel: ObservableObject {

    // Liste des membres du projet
    @Published var members: [ProfileResponse] = []
    
    // Identifiant du propriétaire
    @Published var ownerId: Int?
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    // Identifiant du projet
    let projectId: Int

    init(projectId: Int) {
        self.projectId = projectId
    }

    // Charge les membres du projet
    func fetchMembers() async {
        isLoading = true
        errorMessage = nil

        if AppConfig.version == .dev {
            print("fetchMembers → project:", projectId)
        }

        do {
            let response = try await ProjectService.shared
                .listMembers(projectId: projectId)

            // Mise à jour UI
            ownerId = response.ownerId
            members = response.members
                .sorted { $0.lastName < $1.lastName }

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement."

        } catch {
            if AppConfig.version == .dev {
                print("fetchMembers ERROR:", error.localizedDescription)
            }
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    // Ajoute un membre au projet
    func addMember(userId: Int) async {
        errorMessage = nil

        do {
            try await ProjectService.shared.addMember(
                projectId: projectId,
                userId: userId
            )

            // Rafraîchit la liste après ajout
            await fetchMembers()

        } catch {
            errorMessage = "Impossible d’ajouter le membre."
        }
    }

    // Supprime un membre du projet
    func removeMember(userId: Int) async {
        errorMessage = nil

        // Empêche suppression du owner
        guard ownerId != userId else { return }

        do {
            try await ProjectService.shared.removeMember(
                projectId: projectId,
                userId: userId
            )

            // Rafraîchit la liste après suppression
            await fetchMembers()

        } catch {
            errorMessage = "Impossible de supprimer le membre."
        }
    }
}
