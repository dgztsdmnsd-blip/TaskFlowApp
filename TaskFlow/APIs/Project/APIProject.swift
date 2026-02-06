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
    let owner: ProfileLiteResponse
    let membersCount: Int
}

extension ProjectResponse {

    static let previewNotStarted = ProjectResponse(
        id: 1,
        title: "Refonte du site Web",
        description: "Projet UX/UI complet du site institutionnel.",
        status: .notStarted,
        owner: .preview,
        membersCount: 1
    )

    static let previewInProgress = ProjectResponse(
        id: 2,
        title: "Migration CRM",
        description: "Migration des données vers le nouveau CRM.",
        status: .inProgress,
        owner: .preview,
        membersCount: 4
    )

    static let previewFinished = ProjectResponse(
        id: 3,
        title: "Audit sécurité",
        description: "Analyse complète des failles de sécurité.",
        status: .finished,
        owner: .preview,
        membersCount: 2
    )
}


struct ProjectMembersResponse: Decodable {
    let ownerId: Int
    let members: [ProfileResponse]
}
