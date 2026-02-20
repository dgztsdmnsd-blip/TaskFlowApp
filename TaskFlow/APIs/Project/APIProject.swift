//
//  APIProject.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//
//  Modèles représentant les projets.
//  Contient :
//  - Modes d’utilisation (create / edit / liste)
//  - Statuts avec helpers UI
//  - Structures de réponse API
//

import SwiftUI

// Mode d’utilisation des écrans projet
enum ProjectMode {
    case create
    case edit(projet: ProjectResponse)
    case liste
}

// Statut d’un projet
enum ProjectStatus: String, Codable {
    
    case notStarted = "NS"
    case inProgress = "ENC"
    case finished = "TER"
    
    // Libellé affiché dans l’UI
    var label: String {
        switch self {
        case .notStarted: return "Non démarré"
        case .inProgress: return "En cours"
        case .finished: return "Terminé"
        }
    }

    // Couleur associée au statut
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .finished: return .green
        }
    }
}

// Réponse API complète d’un projet
struct ProjectResponse: Codable, Identifiable {
    
    // Identifiant unique
    let id: Int
    
    // Informations principales
    let title: String
    let description: String
    let status: ProjectStatus

    // Dates du projet
    let startDate: Date?
    let endDate: Date?
    let creationDate: Date?
    let updateDate: Date?
    let completedAt: Date?

    // Relations
    let owner: ProfileLiteResponse
    let members: [ProfileLiteResponse]
    
    // Nombre de membres
    let membersCount: Int
}

// Réponse API pour la gestion des membres
struct ProjectMembersResponse: Decodable {
    
    // Identifiant du propriétaire
    let ownerId: Int
    
    // Liste complète des membres
    let members: [ProfileResponse]
}
