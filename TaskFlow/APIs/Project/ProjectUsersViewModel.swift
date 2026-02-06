//
//  ProjectUsersViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 04/02/2026.
//

import Foundation
import Combine

@MainActor
final class ProjectUsersViewModel: ObservableObject {

    @Published var members: [ProfileResponse] = []
    @Published var ownerId: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let projectId: Int

    init(projectId: Int) {
        self.projectId = projectId
    }

    func fetchMembers() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await ProjectService.shared
                .listMembers(projectId: projectId)

            ownerId = response.ownerId
            members = response.members.sorted { $0.lastName < $1.lastName }

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement."
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    // Ajout d'un membre
    func addMember(userId: Int) async {
        do {
            try await ProjectService.shared.addMember(
                projectId: projectId,
                userId: userId
            )
            await fetchMembers()
        } catch {
            errorMessage = "Impossible d’ajouter le membre"
        }
    }

    // Suppression d'un membre
    func removeMember(userId: Int) async {
        guard ownerId != userId else { return }

        do {
            try await ProjectService.shared.removeMember(
                projectId: projectId,
                userId: userId
            )
            await fetchMembers()
        } catch {
            errorMessage = "Impossible de supprimer le membre"
        }
    }
}

