//
//  APITags.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//

import SwiftUI

enum TagMode {
    case create
    case edit(task: TagResponse)
    case liste
}

struct TagResponse: Codable, Identifiable, Equatable {
    let id: Int
    let tagName: String
    let couleur: String
}

struct TagImpactResponse: Codable {
    let tag: TagMiniResponse
    let projects: [ProjectResponse]
    let userStories: [StoryResponse]
}

struct TagMiniResponse: Codable {
    let id: Int
    let name: String
    let color: String
}
