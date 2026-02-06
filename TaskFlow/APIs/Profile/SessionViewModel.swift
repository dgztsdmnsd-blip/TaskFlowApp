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

    @Published var currentUser: ProfileResponse?
    @Published var isAuthenticated = false

    func loadCurrentUser() async {
        do {
            let profile = try await ProfileService.shared.fetchProfile()
            self.currentUser = profile
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func refreshCurrentUser() async {
        do {
            self.currentUser = try await ProfileService.shared.fetchProfile()
        } catch {
            print("Impossible de rafraîchir le profil")
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}

extension SessionViewModel {
    static var mock: SessionViewModel {
        let vm = SessionViewModel()
        vm.currentUser = .preview
        return vm
    }
}

