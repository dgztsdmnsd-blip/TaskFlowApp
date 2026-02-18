//
//  APIProfile.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Modèle représentant la réponse API du profil utilisateur.
//  Ce fichier contient :
//  - la structure décodable du profil
//  - des helpers de conversion de dates
//  - des propriétés calculées pour l’affichage UI
//

import Foundation

// Structure de réponse de Login
struct ProfileResponse: Codable, Identifiable, Hashable {
    let id: Int
    var email: String
    var firstName: String
    var lastName: String

    let status: String
    let profil: String

    let creationDate: Date
    let exitDate: Date?

    let projectsCount: Int
}


struct ProfileLiteResponse: Codable, Identifiable, Hashable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
}

extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}

extension ProfileResponse {

    var creationDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: creationDate)
    }

    var exitDateFormatted: String {
        guard let exitDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: exitDate)
    }
}
