//
//  APIStories.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI

enum StoryMode {
    case create
    case edit(story: StoryResponse)
    case liste
}

enum StoryStatus: String, Codable {
    case notStarted = "NS"
    case inProgress = "ENC"
    case finished = "TER"
    
    var label: String {
        switch self {
        case .notStarted: return "Non démarrée"
        case .inProgress: return "En cours"
        case .finished: return "Terminé"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .finished: return .green
        }
    }
}

struct StoryResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String

    let dueAt: String?
    let creationDate: String?
    let updateDate: String?
    let completedAt: String?

    let priority: Int?
    let storyPoint: Int?
    let status: StoryStatus

    let project: ProjectResponse
    let owner: ProfileLiteResponse
    let couleur: String
}


struct StoryCreateRequest: Codable {
    let title: String
    let description: String
    let priority: Int?
    let storyPoint: Int?
    let dueAt: String?
    let couleur: String
}

struct StoryUpdateRequest: Codable {
    let title: String?
    let description: String?
    let priority: Int?
    let storyPoint: Int?
    let dueAt: String?
    let couleur: String?
}
