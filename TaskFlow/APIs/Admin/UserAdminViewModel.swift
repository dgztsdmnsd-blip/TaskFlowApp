//
//  UserAdminViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 29/01/2026.
//
//  ViewModel gérant la logique d’administration d’un utilisateur.
//  Permet à un admin de :
//  - Activer / désactiver un compte
//  - Modifier le rôle (manager / utilisateur)

//

import Foundation
import Combine

// ViewModel de gestion d’un utilisateur par un admin
@MainActor
final class UserAdminViewModel: ObservableObject {

    // Utilisateur administré
    @Published var user: ProfileResponse
    
    // Indique un appel réseau en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    init(user: ProfileResponse) {
        self.user = user
    }

    // Indique si l’utilisateur est actif
    var isActive: Bool {
        user.status == AdminUserStatus.active.rawValue
    }

    // Indique si l’utilisateur est manager
    var isManager: Bool {
        user.profil == AdminUserProfil.mgr.rawValue
    }

    // Active / désactive le compte utilisateur
    func toggleStatus() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Détermine le nouveau statut
        let newStatus: AdminUserStatus =
            isActive ? .inactive : .active

        do {
            // Appel API admin
            let response = try await UserAdminService.shared.updateUser(
                id: user.id,
                status: newStatus
            )
            
            // Mise à jour locale
            user = response
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Change le rôle utilisateur (manager / utilisateur)
    func toggleRole() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Détermine le nouveau rôle
        let newProfil: AdminUserProfil =
            isManager ? .util : .mgr

        do {
            // Appel API admin
            let response = try await UserAdminService.shared.updateUser(
                id: user.id,
                profil: newProfil
            )
            
            // Mise à jour locale
            user = response
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
