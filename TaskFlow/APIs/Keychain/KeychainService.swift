//
//  KeychainService.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Gère le stockage du refresh token dans le Keychain.
//  Objectif : garder un refresh token persistant, protégé par biométrie (Face ID / Touch ID),
//  pour pouvoir restaurer une session sans redemander le mot de passe.
//

import Foundation
import Security
import LocalAuthentication

// Erreurs possibles liées au Keychain
enum KeychainError: Error {
    case encoding                 // Impossible de convertir le token en Data
    case decoding                 // Impossible de reconvertir le Data en String (non utilisé ici mais utile)
    case itemNotFound             // Aucun item trouvé dans le Keychain pour ce service/account
    case unhandled(OSStatus)      // Code d’erreur Keychain brut (OSStatus) non géré explicitement
}

final class KeychainService {

    // Un seul point d’accès au Keychain dans toute l’app
    static let shared = KeychainService()
    private init() {}

    // Permet d’isoler tes items des autres apps
    private let service = "TaskFlow"

    //  Sauvegarde du refresh token (protégé biométrie)
    func saveRefreshToken(token: String, account: String) throws {

        // Conversion en Data (le Keychain stocke des octets)
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encoding
        }

        // SecAccessControl décrit la “politique de protection” de l’item Keychain
        // - kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
        //   l’item n’est accessible que quand l’iPhone est déverrouillé
        //   et n’est pas migré/restauré sur un autre appareil (plus sécurisé).
        //
        // - .biometryAny:
        //   oblige l’usage de Face ID / Touch ID (et iOS gère le fallback code si nécessaire).
        //   (À la différence de .userPresence qui peut privilégier le code selon le contexte.)
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [],
            &error
        ) else {
            // Si la création échoue, on remonte l’erreur système détaillée
            throw error!.takeRetainedValue() as Error
        }

        // Dictionnaire “query” décrivant l’item à enregistrer
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,   // type d’item Keychain (mot de passe générique)
            kSecAttrService as String: service,              // namespace applicatif
            kSecAttrAccount as String: account,              // “clé” utilisateur (email)
            kSecValueData as String: data,                   // valeur stockée
            kSecAttrAccessControl as String: accessControl   // contrainte biométrique
        ]

        // On supprime l’éventuel item existant (même service+account) pour éviter errSecDuplicateItem
        SecItemDelete(query as CFDictionary)

        // Ajout dans le Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        // Si ce n’est pas un succès, on remonte le status OSStatus
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
    }

    
    // Lecture du refresh token (déclenche Face ID)
    /// Lit le refresh token depuis le Keychain.
    /// Comme l’item est protégé par biométrie, cette lecture déclenche l’UI Face ID/Touch ID.
    func loadRefreshToken(account: String) throws -> String {

        // LAContext permet de contrôler l’authentification biométrique
        // localizedReason : texte affiché dans la popup Face ID
        // interactionNotAllowed = false : autorise l’UI interactive (sinon iOS peut refuser l’affichage)
        let context = LAContext()
        context.localizedReason = "Se connecter avec Face ID"
        context.interactionNotAllowed = false

        // Query pour retrouver l’item :
        // - kSecReturnData: true => on veut récupérer la donnée stockée
        // - kSecUseAuthenticationContext: fournit le LAContext à utiliser pour l’auth biométrique
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // Si l’item n’existe pas (pas de refresh token stocké pour cet account)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Si succès, on récupère le Data et on le reconvertit en String
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unhandled(status)
        }

        return token
    }

    // Suppression (logout / nettoyage)
    /// Supprime le refresh token du Keychain pour un utilisateur donné.
    /// À appeler lors d’une déconnexion volontaire.
    func clear(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
