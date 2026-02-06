//
//  OwnerProjectsViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 06/02/2026.
//

import Foundation
import Combine

@MainActor
final class OwnerProjectsViewModel: ObservableObject {

    @Published var projects: [ProjectResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?


    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await ProjectService.shared
                .listProjectsForOwner()
        } catch APIError.httpError(_, let message) {
            errorMessage = message
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
