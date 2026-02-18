//
//  APIProject.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import SwiftUI

enum ProjectMode {
    case create
    case edit(projet: ProjectResponse)
    case liste
}

enum ProjectStatus: String, Codable {
    case notStarted = "NS"
    case inProgress = "ENC"
    case finished = "TER"
    
    var label: String {
        switch self {
        case .notStarted: return "Non démarré"
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

struct ProjectResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let status: ProjectStatus

    let startDate: Date?
    let endDate: Date?
    let creationDate: Date?
    let updateDate: Date?
    let completedAt: Date?

    let owner: ProfileLiteResponse
    let members: [ProfileLiteResponse]
    let membersCount: Int
}

struct ProjectMembersResponse: Decodable {
    let ownerId: Int
    let members: [ProfileResponse]
}
