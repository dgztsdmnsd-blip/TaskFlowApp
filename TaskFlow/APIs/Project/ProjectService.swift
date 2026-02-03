//
//  ProjectService.swift
//  TaskFlow
//
//  Created by luc banchetti on 02/02/2026.
//

import Foundation

final class ProjectService {

    static let shared = ProjectService()
    private init() {}

    // Creation
    func createProject(
        title: String,
        description: String
    ) async throws -> ProjectResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/create")

        print("Create Project → URL:", url)

        struct Body: Encodable {
            let title: String
            let description: String
        }

        let response: ProjectResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: Body(
                title: title,
                description: description
            ),
            requiresAuth: true
        )

        print("Create Project succès → id:", response.id)
        return response
    }
    
    
    // Modification
    func updateProject(
        id: Int,
        title: String? = nil,
        description: String? = nil
    ) async throws -> ProjectResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/update/\(id)")

        struct Body: Encodable {
            let title: String?
            let description: String?
        }

        let response: ProjectResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(title: title, description: description),
            requiresAuth: true
        )

        print("Update Project succès → id:", response.id)
        return response
    }
    

    // Liste des projets
    func listProjects() async throws -> [ProjectResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/liste")

        print("Projects List → URL:", url)

        let projects: [ProjectResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("Projects List succès → count:", projects.count)
        return projects
    }

    // Detail d'un projet
    func fetchProject(id: Int) async throws -> ProjectResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/detail/\(id)")

        print("Project Detail → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    // Suppression d'un projet
    func deleteProject(id: Int) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/delete/\(id)")

        print("Delete Project → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        print("Delete Project succès → id:", id)
    }

}
