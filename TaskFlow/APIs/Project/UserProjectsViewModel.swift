//
//  UserProjectsViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import Foundation
import Combine

@MainActor
final class UserProjectsViewModel: ObservableObject {

    @Published var projects: [ProjectResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await ProjectService.shared
                .listProjectsForUser(for: userId)
        } catch APIError.httpError(_, let message) {
            errorMessage = message
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    
    @MainActor
    func assignProjectToUser(projectId: Int) async {
        do {
            try await ProjectService.shared.addMember(
                projectId: projectId,
                userId: userId
            )
            await fetchProjects()
        } catch {
            errorMessage = "Impossible d’attribuer le projet"
        }
    }

}

extension UserProjectsViewModel {
    static var preview: UserProjectsViewModel {
        let vm = UserProjectsViewModel(userId: 1)
        vm.projects = [ProjectResponse.previewInProgress]
        vm.isLoading = false
        return vm
    }
}
