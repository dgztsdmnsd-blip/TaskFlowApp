//
//  StoriesService.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//

import Foundation

final class StoriesService {
    static let shared = StoriesService()
    private init() {}

    // Creation
    func createUserStory(
        projectId : Int,
        title: String,
        description: String,
        dueAt: String? = nil,
        priority: Int? = nil,
        storyPoint: Int? = nil,
        couleur: String
    ) async throws -> StoryResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/\(projectId)/userstories/create")

        print("Create User Story → URL:", url)

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

        if let data = try? JSONEncoder().encode(body),
           let json = String(data: data, encoding: .utf8) {
            print("CREATE USER STORY BODY →", json)
        }


        let response: StoryResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body,
            requiresAuth: true
        )

        print("Create User Story succès → id:", response.id)
        return response
    }
    
    
    // Modification
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
            body: Body(title: title, description: description, dueAt: dueAt, priority: priority, storyPoint: storyPoint, couleur: couleur),
            requiresAuth: true
        )

        print("Update User Story succès → id:", response.id)
        return response
    }
    
    
    // Modification statut
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

        print("Update Story Status")
        print("URL:", url)
        print("Story ID:", userStoryId)
        print("Status envoyé:", status.rawValue)

        do {
            let response: StoryResponse = try await APIClient.shared.request(
                url: url,
                method: "PATCH",
                body: body,
                requiresAuth: true
            )

            print("Update User Story succès")
            print("ID:", response.id)
            print("Nouveau statut:", response.status)

            return response

        } catch {
            print("Erreur Update Story Status")
            print("Story ID:", userStoryId)
            print("Status tenté:", status.rawValue)
            print("Erreur:", error.localizedDescription)

            throw error
        }
    }


    // Liste toutes les user stories
    func listAllUserStories(
        projectId: Int,
        statut: StoryStatus
    )
    async throws -> [StoryResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/\(projectId)/userstories/list/statut/\(statut.rawValue)")

        print("User stories List → URL:", url)

        let stories: [StoryResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("All user stories List succès → count:", stories.count)
        return stories
    }
  
    
    // Liste des user stories par l'utilisateur connecté (owner)
    func listOwnerUserStory(
        projectId: Int,
        statut: StoryStatus
    ) async throws -> [StoryResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/\(projectId)/userstories/list/owner/statut/\(statut.rawValue)")

        print("User story owner List → URL:", url)

        let stories: [StoryResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("User Stories owner List succès → count:", stories.count)
        return stories
    }
    
    
    // Detail d'une user story
    func fetchUserStory(userStoryId: Int) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)")

        print("User Story Detail → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    
    // Suppression d'une user story
    func deleteStory(
        userStoryId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)")

        print("Delete User Story → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        print("Delete User Story succès → id:", userStoryId)
    }
}
