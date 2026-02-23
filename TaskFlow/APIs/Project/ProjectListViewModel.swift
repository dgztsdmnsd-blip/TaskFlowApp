//
//  ProjectListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  ViewModel gérant le chargement et l’état
//  des listes de projets.
//  Supporte :
//  - Tous les projets accessibles
//  - Projets actifs
//  - Gestion loading / erreurs / filtres
//

import Foundation
import Combine

// ViewModel de la liste des projets
@MainActor
final class ProjectListViewModel: ObservableObject {

    // Liste des projets
    @Published var projects: [ProjectResponse] = []
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?
    
    // Stories filtrées (ex: filtre par tag)
    @Published var filteredStories: [StoryResponse]? = nil
    
    // Indique si un filtre tag est actif
    @Published var isTagFilterActive: Bool = false

    // Charge tous les projets accessibles par l’utilisateur
    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        filteredStories = nil

        if AppConfig.version == .dev {
            print("fetchProjects → START")
        }

        do {
            projects = try await ProjectService.shared.listProjects()

            if AppConfig.version == .dev {
                print("fetchProjects → count:", projects.count)
            }

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement des projets."

        } catch {
            if AppConfig.version == .dev {
                print("fetchProjects ERROR:", error.localizedDescription)
            }
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    // Charge uniquement les projets actifs
    func fetchActiveProjects() async {

        isLoading = true
        errorMessage = nil
        filteredStories = nil

        if AppConfig.version == .dev {
            print("fetchActiveProjects → START")
        }

        do {
            projects = try await ProjectService.shared.listActiveProjects()

            if AppConfig.version == .dev {
                print("fetchActiveProjects → count:", projects.count)
            }

        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement des projets."

        } catch {
            if AppConfig.version == .dev {
                print("fetchActiveProjects ERROR:", error.localizedDescription)
            }
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
