//
//  SessionViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 06/02/2026.
//

import Foundation
import Combine

@MainActor
final class SessionViewModel: ObservableObject {

    // Published state
    @Published private(set) var currentUser: ProfileResponse?
    @Published private(set) var isAuthenticated = false

    // Init
    init() {
        restoreSessionIfPossible()
    }

    // Session lifecycle
    /// Tente de restaurer une session existante si un compte est connu
    func restoreSessionIfPossible() {
        guard SessionManager.shared.hasStoredSession else {
            clearSession()
            return
        }

        Task {
            await loadCurrentUser()
        }
    }

    /// Charge le profil utilisateur depuis le backend
    /// La présence d'une session stockée est obligatoire
    func loadCurrentUser() async {
        guard SessionManager.shared.hasStoredSession else {
            clearSession()
            return
        }

        do {
            let profile = try await ProfileService.shared.fetchProfile()
            currentUser = profile
            isAuthenticated = true
        } catch {
            // Token invalide / expiré / refresh impossible
            SessionManager.shared.logout()
            clearSession()
        }
    }

    /// Rafraîchit uniquement les données du profil
    func refreshCurrentUser() async {
        guard isAuthenticated else { return }

        do {
            currentUser = try await ProfileService.shared.fetchProfile()
        } catch {
            print("Impossible de rafraîchir le profil")
        }
    }

    /// Déconnexion complète
    func logout() {
        SessionManager.shared.logout()
        clearSession()
    }

    // Private helpers
    private func clearSession() {
        currentUser = nil
        isAuthenticated = false
    }
}

// Preview
extension SessionViewModel {

    static var mock: SessionViewModel {
        let vm = SessionViewModel()
        vm.currentUser = .preview
        vm.isAuthenticated = true
        return vm
    }
}
