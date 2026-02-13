//
//  TagPickerViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//

import Foundation
import Combine

@MainActor
final class TagPickerViewModel: ObservableObject {

    @Published var tags: [TagResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadTags() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tags = try await TagsService.shared.listTags()
        } catch {
            errorMessage = "Impossible de charger les tags."
        }
    }
}
