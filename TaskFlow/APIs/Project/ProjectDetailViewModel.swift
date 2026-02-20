//
//  ProjectDetailViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  ViewModel gérant la logique de l’écran détail projet.
//  Gère :
//  - Rafraîchissement du projet
//  - Mise à jour du statut
//  - États UI (loading / erreur)
//

import Foundation
import Combine

// ViewModel de l’écran détail projet
@MainActor
final class ProjectDetailViewModel: ObservableObject {

    // Projet affiché
    @Published var project: ProjectResponse
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    init(project: ProjectResponse) {
        self.project = project
    }

    // Recharge les données du projet depuis l’API
    func reload() async {
        isLoading = true
        errorMessage = nil

        do {
            project = try await ProjectService.shared
                .fetchProject(id: project.id)
        } catch {
            errorMessage = "Impossible de rafraîchir le projet."
        }

        isLoading = false
    }
    
    // Met à jour le statut du projet
    func updateStatus(to status: ProjectStatus) async {
        isLoading = true
        errorMessage = nil

        do {
            let updated = try await ProjectService.shared
                .updateProjectStatus(id: project.id, status: status)

            project = updated
        } catch {
            errorMessage = "Impossible de modifier le statut."
        }

        isLoading = false
    }
}
