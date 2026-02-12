//
//  DraggableTask.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct DraggableTask: Codable, Transferable, Identifiable {
    let id: Int

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .taskId)
    }
}

extension UTType {
    static let taskId = UTType(exportedAs: "com.taskflow.task-id")
}
