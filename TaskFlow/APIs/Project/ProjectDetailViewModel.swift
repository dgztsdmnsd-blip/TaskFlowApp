//
//  ProjectDetailViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import Foundation
import Combine

@MainActor
final class ProjectDetailViewModel: ObservableObject {

    @Published var project: ProjectResponse
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(project: ProjectResponse) {
        self.project = project
    }

    func reload() async {
        isLoading = true
        do {
            project = try await ProjectService.shared.fetchProject(id: project.id)
        } catch {
            errorMessage = "Impossible de rafraîchir le projet."
        }
        isLoading = false
    }
}
