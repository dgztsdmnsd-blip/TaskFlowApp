//
//  ProfileViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  ViewModel responsable du chargement et de l’exposition
//  des données de profil utilisateur pour la vue.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: ProfileResponse?

    /// Chargement initial du profil
    func fetchProfile() async {
        guard SessionManager.shared.getAccessToken() != nil else {
            errorMessage = "Session non prête"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            profile = try await ProfileService.shared.fetchProfile()
        } catch APIError.unauthorized {
            errorMessage = "Session expirée. Veuillez vous reconnecter."
        } catch {
            errorMessage = "Impossible de charger le profil."
        }

        isLoading = false
    }

    /// Rechargement explicite après modification
    func reloadProfile() async {
        await fetchProfile()
    }

    /// Droits admin
    var isAdmin: Bool {
        profile?.profil == "MGR"
    }
}

extension ProfileViewModel {

    static let preview: ProfileViewModel = {
        let vm = ProfileViewModel()
        vm.profile = .preview
        return vm
    }()
}
