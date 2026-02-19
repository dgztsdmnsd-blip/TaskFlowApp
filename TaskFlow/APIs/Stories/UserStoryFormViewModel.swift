//
//  UserStoryFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import Foundation
import Combine

@MainActor
final class UserStoryFormViewModel: ObservableObject {

    let mode: StoryMode
    let project: ProjectResponse
    let owner: ProfileLiteResponse

    @Published var titre = ""
    @Published var description = ""
    @Published var dueDate: Date? = nil
    @Published var priority: Int?
    @Published var storyPoint: Int?
    @Published var couleur = "#000000"

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    
    var dueAt: String? {
            guard let dueDate else { return nil }
            return dueDate.formatted(.iso8601.year().month().day())
        }
    
    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    var isFormValid: Bool {
        !titre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        mode: StoryMode,
        project: ProjectResponse,
        owner: ProfileLiteResponse
    ) {
        self.mode = mode
        self.project = project
        self.owner = owner

        if case .edit(let story) = mode {
            titre = story.title
            description = story.description
            priority = story.priority
            storyPoint = story.storyPoint
            couleur = story.couleur

            // Parse robuste de dueAt -> dueDate
            if let dueAt = story.dueAt, !dueAt.isEmpty {

                // 1) ISO8601 (avec fractions)
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let d = iso.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // 2) ISO8601 (sans fractions)
                iso.formatOptions = [.withInternetDateTime]
                if let d = iso.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // 3) "yyyy-MM-dd"
                let f1 = DateFormatter()
                f1.locale = Locale(identifier: "en_US_POSIX")
                f1.timeZone = TimeZone(secondsFromGMT: 0)
                f1.dateFormat = "yyyy-MM-dd"
                if let d = f1.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // 4) "yyyy-MM-dd HH:mm:ss" (au cas où)
                let f2 = DateFormatter()
                f2.locale = Locale(identifier: "en_US_POSIX")
                f2.timeZone = TimeZone(secondsFromGMT: 0)
                f2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let d = f2.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // Si on arrive ici, le format n'est pas reconnu
                // (optionnel) print pour debug
                print("Impossible de parser dueAt:", dueAt)
            }
        }

    }

    func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            return
        }

        do {
            switch mode {
            case .create:
                _ = try await StoriesService.shared.createUserStory(
                    projectId: project.id,
                    title: titre,
                    description: description,
                    dueAt: dueAt,
                    priority: priority,
                    storyPoint: storyPoint,
                    couleur: couleur
                )

            case .edit(let story):
                _ = try await StoriesService.shared.updateUserStory(
                    userStoryId: story.id,
                    title: titre,
                    description: description,
                    dueAt: dueAt,
                    priority: priority,
                    storyPoint: storyPoint,
                    couleur: couleur
                )

            case .liste:
                break
            }

            isSuccess = true

        } catch {
            errorMessage = "Erreur réseau ou validation."
        }
    }
}
