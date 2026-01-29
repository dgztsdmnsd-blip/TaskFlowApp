//
//  SessionManager.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Responsable de la gestion de la session utilisateur.
//  Il fait le lien entre :
//  - l’état applicatif (utilisateur courant)
//  - les tokens (access token en mémoire, refresh token sécurisé)
//  - le cycle de vie de la session (login / reconnexion / logout)
//

import Foundation

final class SessionManager {

    // Une seule session partagée dans toute l’app
    static let shared = SessionManager()
    private init() {}
    
    var hasStoredSession: Bool {
        currentAccount != nil
    }

    // Utilisateur courant
    private let accountKey = "currentAccount"

    private var currentAccount: String? {
        get { UserDefaults.standard.string(forKey: accountKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: accountKey) }
    }

    /// Démarrage de session (login classique)
    func startSession(email: String, accessToken: String, refreshToken: String) throws {
        currentAccount = email
        saveAccessToken(accessToken)
        try KeychainService.shared.saveRefreshToken(
            token: refreshToken,
            account: email
        )
    }

    // Access token (mémoire uniquement)
    private var accessToken: String?

    /// Enregistre un nouvel access token (login ou refresh).
    func saveAccessToken(_ token: String) {
        accessToken = token
    }

    /// Retourne l’access token courant s’il existe.
    func getAccessToken() -> String? {
        accessToken
    }

    /// Refresh token (Keychain + biométrie)
    func getRefreshToken() throws -> String {
        guard let account = currentAccount else {
            throw APIError.unauthorized(message: "Utilisateur inconnu")
        }
        return try KeychainService.shared.loadRefreshToken(account: account)
    }

    /// Refresh token (Keychain + biométrie)
    func clear() {
        accessToken = nil
    }
    
    // Déconnexion complète
    func logout() {
        // Supprime l’access token en mémoire
        accessToken = nil

        // Supprime le refresh token du Keychain si un compte existe
        if let account = currentAccount {
            KeychainService.shared.clear(account: account)
        }

        // Supprime l’utilisateur courant
        currentAccount = nil
    }
    
    func updateRefreshToken(_ token: String) throws {
        guard let account = currentAccount else {
            throw APIError.unauthorized(message: "Utilisateur inconnu")
        }

        try KeychainService.shared.saveRefreshToken(
            token: token,
            account: account
        )
    }


}
