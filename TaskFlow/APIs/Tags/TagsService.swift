//
//  TagsService.swift
//  TaskFlow
//
//  Created by luc banchetti on 12/02/2026.
//

import Foundation

final class TagsService {
    static let shared = TagsService()
    private init() {}
    
    // Tag creation
    func createTag(
        tagName: String,
        couleur: String
    ) async throws -> TagResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/tag/create")

        print("Create Tag → URL:", url)

        struct Body: Encodable {
            let tagName: String
            let couleur: String
        }
        
        let body = Body(
            tagName: tagName,
            couleur: couleur
        )

        if let data = try? JSONEncoder().encode(body),
           let json = String(data: data, encoding: .utf8) {
            print("CREATE TAG BODY →", json)
        }

        let response: TagResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body,
            requiresAuth: true
        )

        print("Create Tag succès → id:", response.id)
        return response
    }
    
   
    // Tag modification
    func updateTagColor(
        tagId: Int,
        couleur: String
    ) async throws -> TagResponse {
        guard couleur.firstMatch(of: /#[0-9A-Fa-f]{6}/) != nil else {
            throw APIError.invalidColor
        }
        
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tag/update/\(tagId)")

        struct Body: Encodable {
            let couleur: String
        }

        let response: TagResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(
                couleur: couleur
            ),
            requiresAuth: true
        )

        print("Update Tag réussie succès → id:", response.id)
        return response
    }
    
  
    // Liste des tags
    func listTags()
    async throws -> [TagResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/tag/liste")

        print("Tags List → URL:", url)

        let tags: [TagResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("Tags List succès → count:", tags.count)
        return tags
    }
    

    // Detail d'un tag
    func fetchTag(
        tagId: Int
    ) async throws -> TagResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tag/detail/\(tagId)")

        print("Tag Detail → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    
    // Suppression d'un tag
    func deleteTag(
        tagId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tag/delete/\(tagId)")

        print("Delete Tag → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        print("Delete Tag succès → id:", tagId)
    }
    
    
    // Affectation d'un tag à une user story
    func attachTag(
        tagId: Int,
        toStory userstoryId: Int
    ) async throws -> StoryResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tag/addtag/\(tagId)/userstory/\(userstoryId)")

        print("Tag to User Story → URL:", url)
        print("Attach Tag \(tagId) → Story \(userstoryId)")

        return try await APIClient.shared.request(
            url: url,
            method: "POST",
            requiresAuth: true
        )
    }
    
    
    
    // Suppression d'un tag d'une user story
    func detachTag(
        tagId: Int,
        fromStory userstoryId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tag/deltag/\(tagId)/userstory/\(userstoryId)")

        print("Detach Tag from Story <- URL:", url)
        print("Detach Tag \(tagId) <- Story \(userstoryId)")

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        print("Detach Tag from Story succès → id:", tagId)
    }
    
    
    // Impact d’un tag (liste des projets et user stories associés)
     func fetchTagImpact(
         tagId: Int
     ) async throws -> TagImpactResponse {

         let url = AppConfig.baseURL
             .appendingPathComponent("/api/tag/impact/\(tagId)")

         print("Tag Impact → URL:", url)

         return try await APIClient.shared.request(
             url: url,
             method: "GET",
             requiresAuth: true
         )
     }
}


