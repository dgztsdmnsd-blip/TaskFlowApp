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
    
    // Modification statut
    func updateProjectStatus(
        id: Int,
        status: ProjectStatus
    ) async throws -> ProjectResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/status/\(id)")

        struct Body: Encodable {
            let status: String
        }

        let response: ProjectResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(status: status.rawValue),
            requiresAuth: true
        )

        print("Update Project succès → id:", response.id)
        return response
    }
    

    // Liste des projets accessibles par l'utilisateur connecté (membre ou owner)
    // ProjectsView et UserProjectsView
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
  
    
    // Liste des projets en cours accessibles par l'utilisateur connecté (membre ou owner)
    // BacklogView
    func listActiveProjects() async throws -> [ProjectResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/projects/activeprojects")

        print("Projects active List → URL:", url)

        let projects: [ProjectResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("Projects active List succès → count:", projects.count)
        return projects
    }
    
    
    // Liste des membres    
    func listMembers(
        projectId: Int
    ) async throws -> ProjectMembersResponse {
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/\(projectId)/members")
        
        print("Members List → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
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
    
    
    // Ajout d'un membre
    func addMember(
        projectId: Int,
        userId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/projet/\(projectId)/member/\(userId)")

        print("Add Member → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "POST",
            requiresAuth: true
        ) as EmptyResponse
    }

    
    // Suppression d'un membre
    func removeMember(
        projectId: Int,
        userId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/projet/\(projectId)/member/\(userId)")

        print("Remove Member → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse
    }

    
    // Projets pour un utilisateur donné
    func listProjectsForUser(
        for userId: Int
    ) async throws -> [ProjectResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/user/\(userId)")

        print("User Projects → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }
    
    
    // Projets pour un owner donné
    func listProjectsForOwner() async throws -> [ProjectResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/projects/owner")

        print("User Projects → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

}
