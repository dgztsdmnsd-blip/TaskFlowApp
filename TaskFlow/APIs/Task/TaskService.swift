//
//  TaskService.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//

import Foundation

final class TaskService {
    static let shared = TaskService()
    private init() {}

    
    // Creation
    func createTask(
        userStoryId : Int,
        title: String,
        description: String,
        type: String,
        storyPoint: Int? = nil
    ) async throws -> TaskResponse {

        let url = AppConfig.baseURL.appendingPathComponent("/api/userstories/\(userStoryId)/tasks/create")

        print("Create Task → URL:", url)

        struct Body: Encodable {
            let title: String
            let description: String
            let type: String
            let storyPoint: Int?
        }
        
        let body = Body(
            title: title,
            description: description,
            type: type,
            storyPoint: storyPoint
        )

        if let data = try? JSONEncoder().encode(body),
           let json = String(data: data, encoding: .utf8) {
            print("CREATE TASK BODY →", json)
        }

        let response: TaskResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body,
            requiresAuth: true
        )

        print("Create Task succès → id:", response.id)
        return response
    }
    

    // Modification
    func updateTask(
        taskId: Int,
        title: String? = nil,
        description: String? = nil,
        type: String? = nil,
        storyPoint: Int? = nil
    ) async throws -> TaskResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/update/\(taskId)")

        struct Body: Encodable {
            let title: String?
            let description: String?
            let type: String?
            let storyPoint: Int?
        }

        let response: TaskResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(title: title, description: description, type: type, storyPoint: storyPoint),
            requiresAuth: true
        )

        print("Update Task succès → id:", response.id)
        return response
    }
    
    
    // Modification statut
    func updateTaskStatus(
        taskId: Int,
        status: TaskStatus
    ) async throws -> TaskResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/\(taskId)/status")

        struct Body: Encodable {
            let status: String
        }

        let body = Body(status: status.rawValue)

        print("Update Task Status")
        print("URL:", url)
        print("Task ID:", taskId)
        print("Status envoyé:", status.rawValue)

        do {
            let response: TaskResponse = try await APIClient.shared.request(
                url: url,
                method: "PATCH",
                body: body,
                requiresAuth: true
            )

            print("Update Task succès")
            print("Task ID:", response.id)
            print("Nouveau statut:", response.status)

            return response

        } catch {
            print("Erreur Update Task Status")
            print("Task ID:", taskId)
            print("Status tenté:", status.rawValue)
            print("Erreur:", error.localizedDescription)

            throw error
        }
    }

    

    // Liste des tâches
    func listTasks(
        userStoryId: Int,
        statut: String
    )
    async throws -> [TaskListResponse] {

        let url = AppConfig.baseURL.appendingPathComponent("/api/userstories/\(userStoryId)/tasks/list/statut/\(statut)")

        print("Tasks List → URL:", url)

        let tasks: [TaskListResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        print("Tasks List succès → count:", tasks.count)
        return tasks
    }
    
    
    // Detail d'une tâche
    func fetchTask(
        taskId: Int
    ) async throws -> TaskResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/detail/\(taskId)")

        print("Task Detail → URL:", url)

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    
    // Suppression d'une tâche
    func deleteTask(
        taskId: Int
    ) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/delete/\(taskId)")

        print("Delete Task → URL:", url)

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        print("Delete Task succès → id:", taskId)
    }
}
