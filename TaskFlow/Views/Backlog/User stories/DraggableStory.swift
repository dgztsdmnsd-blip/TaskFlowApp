//
//  DraggableStory.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Modèle utilisé pour le Drag & Drop des User Stories.
//  Transporte uniquement l’identifiant de la story.
//

import SwiftUI
import UniformTypeIdentifiers

// DraggableStory
// Objet transférable pendant une interaction Drag & Drop
struct DraggableStory: Codable, Transferable, Identifiable {

    // Identifiant unique de la User Story
    let id: Int

    // Transfer Representation
    // Définit comment l’objet est sérialisé lors du drag
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .storyId)
    }
}

// UTType Extension
// Type personnalisé pour identifier le payload Drag & Drop
extension UTType {

    // Type UTType personnalisé pour une Story
    static let storyId = UTType(exportedAs: "com.taskflow.story-id")
}
