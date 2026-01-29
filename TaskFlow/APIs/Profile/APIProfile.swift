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
struct ProfileResponse: Codable, Identifiable {
    let id: Int
    var email: String
    var firstName: String
    var lastName: String
    let status: String
    let profil: String
    let creationDate: String
    let exitDate: String?    
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
        return formatter.string(from: creationDate.toDate() ?? Date())
    }
    
    
    var exitDateFormatted: String {
        guard let exitDate, let date = exitDate.toDate() else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
