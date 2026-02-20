//
//  APITask.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//
//  Modèles représentant les tâches et leur état.
//  Contient :
//  - Modes d’utilisation (create / edit / liste)
//  - Statuts de tâche avec helpers UI
//  - Structures de réponse API
//

import SwiftUI

// Mode d’utilisation de l’écran tâche
enum TaskMode {
    case create
    case edit(task: TaskResponse)
    case liste
}

// Statut d’une tâche
enum TaskStatus: String, Codable {
    
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
    
    // Statut suivant (workflow simple)
    var nextStatus: TaskStatus {
        switch self {
        case .notStarted: return .inProgress
        case .inProgress: return .finished
        case .finished: return .notStarted
        }
    }
}

// Réponse API complète d’une tâche
struct TaskResponse: Codable, Identifiable {
    
    let id: Int
    let title: String
    let description: String
    
    // Dates (format backend brut)
    let creationDate: String?
    let updateDate: String?
    let completedAt: String?

    // Métadonnées tâche
    let type: String
    let storyPoint: Int?
    let status: TaskStatus

    // User story associée
    let userStory: StoryResponse
}

// Réponse API légère pour affichage en liste
struct TaskListResponse: Identifiable, Codable, Equatable {
    
    let id: Int
    let title: String
    let type: String
    let storyPoint: Int?
    var status: TaskStatus
}
