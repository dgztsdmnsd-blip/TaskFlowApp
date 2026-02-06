//
//  UsersListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 27/01/2026.
//

import Foundation
import Combine

@MainActor
final class UsersListViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var users: [ProfileResponse] = []

    /// Récupère le profil de l’utilisateur connecté depuis l’API.
    func fetchUsersList() async {
        isLoading = true
        errorMessage = nil

        do {
            users = try await UsersListService.shared.fetchUsers()
        } catch APIError.unauthorized {
            errorMessage = "Session expirée. Veuillez vous reconnecter."
        } catch {
            errorMessage = "Impossible de charger le profil."
        }

        isLoading = false
    }
}


@MainActor
extension UsersListViewModel {
    static func preview() -> UsersListViewModel {
        let vm = UsersListViewModel()
        vm.isLoading = false
        vm.errorMessage = nil
        vm.users = [
            .preview,   // id 1
            .preview2,  // id 2
            ProfileResponse(
                id: 15,
                email: "owner@test.com",
                firstName: "Owner",
                lastName: "Project",
                status: "ACTIVE",
                profil: "MGR",
                creationDate: "2026-02-03",
                exitDate: nil,
                projectsCount: 2
            )
        ]
        return vm
    }
}
