//
//  UserAdminViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//
//  ViewModel responsable de la logique de modification du profil par un Admin
//

import Foundation
import Combine

@MainActor
final class UserAdminViewModel: ObservableObject {

    @Published var user: ProfileResponse
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(user: ProfileResponse) {
        self.user = user
    }

    var isActive: Bool {
        user.status == AdminUserStatus.active.rawValue
    }

    var isManager: Bool {
        user.profil == AdminUserProfil.mgr.rawValue
    }

    func toggleStatus() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let newStatus: AdminUserStatus =
            isActive ? .inactive : .active

        do {
            let response = try await UserAdminService.shared.updateUser(
                id: user.id,
                status: newStatus
            )
            user = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleRole() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let newProfil: AdminUserProfil =
            isManager ? .util : .mgr

        do {
            let response = try await UserAdminService.shared.updateUser(
                id: user.id,
                profil: newProfil
            )
            user = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
