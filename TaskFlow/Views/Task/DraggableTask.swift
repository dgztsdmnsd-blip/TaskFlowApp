//
//  DraggableTask.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//
//  Modèle utilisé pour le Drag & Drop des tâches
//

import SwiftUI
import UniformTypeIdentifiers

// Représente une tâche transférable pendant un drag
struct DraggableTask: Codable, Transferable, Identifiable {
    
    // Identifiant unique de la tâche
    let id: Int

    // Décrit comment la tâche est sérialisée
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .taskId)
    }
}

// Type UTType personnalisé pour le Drag & Drop tâche
extension UTType {
    
    // Identifie le payload "task-id"
    static let taskId = UTType(exportedAs: "com.taskflow.task-id")
}
