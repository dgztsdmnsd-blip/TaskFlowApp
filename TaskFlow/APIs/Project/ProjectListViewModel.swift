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
    @Published var filteredStories: [StoryResponse]? = nil
    @Published var isTagFilterActive: Bool = false    

    // Liste des projets accessibles par l'utilisateur connecté (membre ou owner)
    // ProjectsView et UserProjectsView
    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        filteredStories = nil
        

        do {
            projects = try await ProjectService.shared.listProjects()
        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement des projets."
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
    
    // Liste des projets encours accessibles par l'utilisateur connecté (membre ou owner)
    // BacklogView
    func fetchActiveProjects() async {
        isLoading = true
        errorMessage = nil
        filteredStories = nil

        do {
            projects = try await ProjectService.shared.listActiveProjects()
        } catch APIError.httpError(_, let message) {
            errorMessage = message ?? "Erreur lors du chargement des projets."
        } catch {
            print("CATCH TRIGGERED")
            print(error)
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
