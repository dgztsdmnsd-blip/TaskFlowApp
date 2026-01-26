//
//  KeychainService.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
/*
import Security
import Foundation

final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    func save(_ value: String, for key: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }

        return String(decoding: data, as: UTF8.self)
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
*/


import Foundation
import Security
import LocalAuthentication

enum KeychainError: Error {
    case encoding
    case decoding
    case itemNotFound
    case unhandled(OSStatus)
}

final class KeychainService {

    static let shared = KeychainService()
    private init() {}

    private let service = "TaskFlow"

    // 🔐 Sauvegarde refresh token (protégé Face ID)
    func saveRefreshToken(token: String, account: String) throws {

        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encoding
        }

        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet],
            &error
        ) else {
            throw error!.takeRetainedValue() as Error
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: accessControl
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
    }

    // 🔓 Lecture refresh token (Face ID)
    func loadRefreshToken(account: String) throws -> String {

        let context = LAContext()
        context.localizedReason = "Se connecter avec Face ID"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unhandled(status)
        }

        return token
    }

    // 🧹 Nettoyage
    func clear(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
