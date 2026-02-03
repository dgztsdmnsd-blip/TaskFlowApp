//
//  ProjectListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import Foundation
import Combine

@MainActor
final class ProjectListViewModel: ObservableObject {

    @Published var projects: [ProjectResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await ProjectService.shared.listProjects()
        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement des projets."
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}

@MainActor
extension ProjectListViewModel {

    static func preview() -> ProjectListViewModel {
        let vm = ProjectListViewModel()

        vm.isLoading = false
        vm.errorMessage = nil
        vm.projects = [
            .previewNotStarted,
            .previewInProgress,
            .previewFinished
        ]

        return vm
    }
}
