//
//  OwnerProjectsViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 06/02/2026.
//
//  ViewModel gérant le chargement et l’état
//  des projets appartenant à l’utilisateur connecté.
//  Gère :
//  - Chargement API
//  - États UI (loading / erreur / données)
//

import Foundation
import Combine

// ViewModel des projets de l’utilisateur (owner)
@MainActor
final class OwnerProjectsViewModel: ObservableObject {

    // Liste des projets
    @Published var projects: [ProjectResponse] = []
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    // Charge les projets du propriétaire connecté
    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            // Appel service
            projects = try await ProjectService.shared
                .listProjectsForOwner()

        } catch APIError.httpError(_, let message) {
            // Erreur backend
            errorMessage = message

        } catch {
            // Erreur réseau / inconnue
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
