//
//  ProfileViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: ProfileResponse?

    func fetchProfile() async {
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
}
