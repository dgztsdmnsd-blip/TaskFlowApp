//
//  UserStoryFormViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  ViewModel gérant le formulaire de user story.
//  Supporte :
//  - Création
//  - Édition
//  - Validation des champs
//  - Gestion des états UI
//

import Foundation
import Combine
import SwiftUI

// ViewModel du formulaire User Story
@MainActor
final class UserStoryFormViewModel: ObservableObject {

    // Mode du formulaire (create / edit)
    let mode: StoryMode
    
    // Projet associé
    let project: ProjectResponse
    
    // Owner de la user story
    let owner: ProfileLiteResponse

    // Champs du formulaire
    @Published var titre = ""
    @Published var description = ""
    @Published var dueDate: Date? = nil
    @Published var priority: Int?
    @Published var storyPoint: Int?
    @Published var couleur = "#000000"

    // États UI
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    
    // Date formatée pour le backend
    var dueAt: String? {
        guard let dueDate else { return nil }
        return dueDate.formatted(.iso8601.year().month().day())
    }
    
    // Indique si on édite une user story existante
    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    // Validation du formulaire
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

        // Pré-remplissage en mode édition
        if case .edit(let story) = mode {
            titre = story.title
            description = story.description
            priority = story.priority
            storyPoint = story.storyPoint
            couleur = story.couleur

            // Parsing robuste dueAt → dueDate
            if let dueAt = story.dueAt, !dueAt.isEmpty {

                let iso = ISO8601DateFormatter()

                // ISO8601 avec fractions
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let d = iso.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // ISO8601 sans fractions
                iso.formatOptions = [.withInternetDateTime]
                if let d = iso.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // Format "yyyy-MM-dd"
                let f1 = DateFormatter()
                f1.locale = Locale(identifier: "en_US_POSIX")
                f1.timeZone = TimeZone(secondsFromGMT: 0)
                f1.dateFormat = "yyyy-MM-dd"
                if let d = f1.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // Format "yyyy-MM-dd HH:mm:ss"
                let f2 = DateFormatter()
                f2.locale = Locale(identifier: "en_US_POSIX")
                f2.timeZone = TimeZone(secondsFromGMT: 0)
                f2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let d = f2.date(from: dueAt) {
                    dueDate = d
                    return
                }

                // Debug si format inconnu
                if AppConfig.version == .dev {
                    print("Impossible de parser dueAt:", dueAt)
                }
            }
        }
    }

    // Soumet le formulaire
    func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Validation locale
        guard isFormValid else {
            errorMessage = "Veuillez remplir le titre et la description."
            return
        }

        do {
            switch mode {

            case .create:
                // Création user story
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
                // Mise à jour user story
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

        } catch APIError.httpError(_, let message) {

            // Message Symfony / backend
            errorMessage = message ?? "Erreur serveur"

        } catch APIError.decodingError {

            // Backend réponse invalide
            errorMessage = "Réponse serveur invalide"

        } catch {

            // Réseau pur (offline / timeout)
            errorMessage = "Erreur réseau"
        }
    }
}
