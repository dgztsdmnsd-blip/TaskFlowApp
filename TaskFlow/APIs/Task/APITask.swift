//
//  APITask.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import SwiftUI

enum TaskMode {
    case create
    case edit(task: TaskResponse)
    case liste
}

enum TaskStatus: String, Codable {
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
    
    var nextStatus: TaskStatus {
        switch self {
        case .notStarted: return .inProgress
        case .inProgress: return .finished
        case .finished: return .notStarted
        }
    }
}

struct TaskResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    
    let creationDate: String?
    let updateDate: String?
    let completedAt: String?

    let type: String
    let storyPoint: Int?
    let status: TaskStatus

    let userStory: StoryResponse
}

struct TaskListResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let type: String
    let storyPoint: Int?
    let status: TaskStatus
}

