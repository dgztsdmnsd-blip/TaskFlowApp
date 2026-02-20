//
//  APITags.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//
//  Modèles représentant les tags et leurs impacts.
//  Contient :
//  - Modes d’utilisation (create / edit / liste)
//  - Structures de réponse API (tag complet / mini / impact)
//

import SwiftUI

// Mode d’utilisation des écrans liés aux tags
enum TagMode {
    case create
    case edit(task: TagResponse)
    case liste
}

// Réponse API complète d’un tag
struct TagResponse: Codable, Identifiable, Equatable {
    
    // Identifiant unique du tag
    let id: Int
    
    // Nom du tag
    let tagName: String
    
    // Couleur du tag (format backend, ex: hex)
    let couleur: String
}

// Réponse API représentant l’impact d’un tag
struct TagImpactResponse: Codable {
    
    // Tag concerné (version légère)
    let tag: TagMiniResponse
    
    // Projets associés au tag
    let projects: [ProjectResponse]
    
    // User stories associées
    let userStories: [StoryResponse]
}

// Version légère d’un tag (ex: listes / badges)
struct TagMiniResponse: Codable {
    
    let id: Int
    let name: String
    let color: String
}
