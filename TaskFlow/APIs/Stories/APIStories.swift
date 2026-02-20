//
//  APIStories.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Modèles représentant les user stories.
//  Contient :
//  - Modes d’utilisation (create / edit / liste)
//  - Statuts avec helpers UI
//  - Structure de réponse API
//

import SwiftUI

// Mode d’utilisation des écrans user story
enum StoryMode {
    case create
    case edit(story: StoryResponse)
    case liste
}

// Statut d’une user story
enum StoryStatus: String, Codable {
    
    case notStarted = "NS"
    case inProgress = "ENC"
    case finished = "TER"
    
    // Libellé affiché dans l’UI
    var label: String {
        switch self {
        case .notStarted: return "Non démarrée"
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

// Réponse API complète d’une user story
struct StoryResponse: Codable, Identifiable {
    
    // Identifiant unique
    let id: Int
    
    // Informations principales
    let title: String
    let description: String

    // Dates
    let dueAt: String?
    let creationDate: String?
    let updateDate: String?
    let completedAt: String?

    // Métadonnées
    let priority: Int?
    let storyPoint: Int?
    let status: StoryStatus

    // Relations
    let project: ProjectResponse
    let owner: ProfileLiteResponse
    
    // Couleur associée
    let couleur: String
    
    // Progression (0 → 1)
    let progress: Double
    
    // Tags associés
    let tags: [TagResponse]
}
