//
//  UsersListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 27/01/2026.
//
//  ViewModel gérant la récupération et l’état
//  de la liste des utilisateurs.
//  Gère les états : chargement, erreur, données.
//

import Foundation
import Combine

// ViewModel de la liste des utilisateurs
@MainActor
final class UsersListViewModel: ObservableObject {

    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?
    
    // Liste des utilisateurs
    @Published var users: [ProfileResponse] = []

    // Récupère la liste des utilisateurs depuis l’API
    func fetchUsersList() async {
        isLoading = true
        errorMessage = nil

        do {
            // Appel service
            users = try await UsersListService.shared.fetchUsers()
            
        } catch APIError.unauthorized {
            // Session expirée
            errorMessage = "Session expirée. Veuillez vous reconnecter."
            
        } catch {
            // Erreur générique
            errorMessage = "Impossible de charger les utilisateurs."
        }

        isLoading = false
    }
}
