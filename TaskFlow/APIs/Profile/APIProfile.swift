//
//  APIProfile.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Modèles représentant les réponses API liées au profil utilisateur.
//  Contient :
//  - Le profil complet
//  - Une version légère (lite)
//  - Des helpers de formatage pour l’UI
//

import Foundation

// Réponse API contenant les informations complètes du profil
struct ProfileResponse: Codable, Identifiable, Hashable {
    
    // Identifiant unique utilisateur
    let id: Int
    
    // Informations principales
    var email: String
    var firstName: String
    var lastName: String

    // Statut et rôle utilisateur
    let status: String
    let profil: String

    // Dates de cycle de vie
    let creationDate: Date
    let exitDate: Date?

    // Statistiques
    let projectsCount: Int
}

// Version légère du profil (ex: listes)
struct ProfileLiteResponse: Codable, Identifiable, Hashable {
    
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
}

// Helper de conversion String → Date ISO8601
extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}

// Helpers UI pour le profil complet
extension ProfileResponse {

    // Date de création formatée pour affichage
    var creationDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: creationDate)
    }

    // Date de sortie formatée (si existante)
    var exitDateFormatted: String {
        guard let exitDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: exitDate)
    }
}
