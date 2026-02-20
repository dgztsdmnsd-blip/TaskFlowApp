//
//  StoriesService.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  Service réseau responsable de la gestion des user stories :
//  - Création
//  - Modification
//  - Changement de statut
//  - Listes (toutes / owner)
//  - Détail
//  - Suppression
//

import Foundation

// Service de gestion des user stories
final class StoriesService {

    // Instance partagée (Singleton)
    static let shared = StoriesService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Création d’une nouvelle user story
    func createUserStory(
        projectId: Int,
        title: String,
        description: String,
        dueAt: String? = nil,
        priority: Int? = nil,
        storyPoint: Int? = nil,
        couleur: String
    ) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/\(projectId)/userstories/create")

        if AppConfig.version == .dev {
            print("Create User Story → URL:", url)
        }

        struct Body: Encodable {
            let title: String
            let description: String
            let dueAt: String?
            let priority: Int?
            let storyPoint: Int?
            let couleur: String
        }
        
        let body = Body(
            title: title,
            description: description,
            dueAt: dueAt,
            priority: priority,
            storyPoint: storyPoint,
            couleur: couleur
        )

        // Log debug JSON
        if let data = try? JSONEncoder().encode(body),
           let json = String(data: data, encoding: .utf8),
           AppConfig.version == .dev {
            print("Create User Story → Body:", json)
        }

        let response: StoryResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body,
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Create User Story succès → id:", response.id)
        }
        
        return response
    }
    
    // Mise à jour d’une user story
    func updateUserStory(
        userStoryId: Int,
        title: String? = nil,
        description: String? = nil,
        dueAt: String? = nil,
        priority: Int? = nil,
        storyPoint: Int? = nil,
        couleur: String? = nil
    ) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)")

        if AppConfig.version == .dev {
            print("Update User Story → URL:", url)
        }

        struct Body: Encodable {
            let title: String?
            let description: String?
            let dueAt: String?
            let priority: Int?
            let storyPoint: Int?
            let couleur: String?
        }

        let response: StoryResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(
                title: title,
                description: description,
                dueAt: dueAt,
                priority: priority,
                storyPoint: storyPoint,
                couleur: couleur
            ),
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Update User Story succès → id:", response.id)
        }
        
        return response
    }
    
    // Mise à jour du statut d’une user story
    func updateStoryStatus(
        userStoryId: Int,
        status: StoryStatus
    ) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)/status")

        struct Body: Encodable {
            let status: String
        }

        let body = Body(status: status.rawValue)

        if AppConfig.version == .dev {
            print("Update Story Status → URL:", url)
            print("Story ID:", userStoryId)
            print("Status:", status.rawValue)
        }

        do {
            let response: StoryResponse = try await APIClient.shared.request(
                url: url,
                method: "PATCH",
                body: body,
                requiresAuth: true
            )

            if AppConfig.version == .dev {
                print("Update Story Status succès →", response.status)
            }

            return response

        } catch {
            if AppConfig.version == .dev {
                print("Update Story Status erreur →", error.localizedDescription)
            }
            throw error
        }
    }

    // Liste toutes les user stories d’un projet
    func listAllUserStories(
        projectId: Int,
        statut: StoryStatus
    ) async throws -> [StoryResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/\(projectId)/userstories/list/statut/\(statut.rawValue)")

        if AppConfig.version == .dev {
            print("All User Stories → URL:", url)
        }

        let stories: [StoryResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("All User Stories succès → count:", stories.count)
        }
        
        return stories
    }
  
    // Liste des user stories de l’utilisateur connecté (owner)
    func listOwnerUserStory(
        projectId: Int,
        statut: StoryStatus
    ) async throws -> [StoryResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/\(projectId)/userstories/list/owner/statut/\(statut.rawValue)")

        if AppConfig.version == .dev {
            print("Owner User Stories → URL:", url)
        }

        let stories: [StoryResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Owner User Stories succès → count:", stories.count)
        }
        
        return stories
    }
    
    // Récupère le détail d’une user story
    func fetchUserStory(userStoryId: Int) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)")

        if AppConfig.version == .dev {
            print("User Story Detail → URL:", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    // Supprime une user story
    func deleteStory(userStoryId: Int) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)")

        if AppConfig.version == .dev {
            print("Delete User Story → URL:", url)
        }

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        if AppConfig.version == .dev {
            print("Delete User Story succès → id:", userStoryId)
        }
    }
}
