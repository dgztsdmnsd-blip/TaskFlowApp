//
//  DraggableStory.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct DraggableStory: Codable, Transferable, Identifiable {
    let id: Int

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .storyId)
    }
}

extension UTType {
    static let storyId = UTType(exportedAs: "com.taskflow.story-id")
}
