//
//  TaskService.swift
//  TaskFlow
//
//  Created by luc banchetti on 10/02/2026.
//
//  Service réseau responsable de la gestion des tâches :
//  - Création
//  - Modification
//  - Changement de statut
//  - Liste
//  - Détail
//  - Suppression
//

import Foundation

// Service de gestion des tâches
final class TaskService {

    // Instance partagée (Singleton)
    static let shared = TaskService()
    
    // Empêche l’instanciation externe
    private init() {}

    // Création d’une nouvelle tâche
    func createTask(
        userStoryId: Int,
        title: String,
        description: String,
        type: String,
        storyPoint: Int? = nil
    ) async throws -> TaskResponse {

        // URL API
        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)/tasks/create")

        if AppConfig.version == .dev {
            print("Create Task → URL:", url)
        }

        // Body envoyé au backend
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

        // Log debug JSON
        if let data = try? JSONEncoder().encode(body),
           let json = String(data: data, encoding: .utf8) {
            if AppConfig.version == .dev {
                print("Create Task → Body:", json)
            }
        }

        // Requête POST authentifiée
        let response: TaskResponse = try await APIClient.shared.request(
            url: url,
            method: "POST",
            body: body,
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Create Task succès → id:", response.id)
        }
        return response
    }

    // Mise à jour d’une tâche existante
    func updateTask(
        taskId: Int,
        title: String? = nil,
        description: String? = nil,
        type: String? = nil,
        storyPoint: Int? = nil
    ) async throws -> TaskResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/update/\(taskId)")

        if AppConfig.version == .dev {
            print("Update Task → URL:", url)
        }

        struct Body: Encodable {
            let title: String?
            let description: String?
            let type: String?
            let storyPoint: Int?
        }

        // Requête PATCH authentifiée
        let response: TaskResponse = try await APIClient.shared.request(
            url: url,
            method: "PATCH",
            body: Body(
                title: title,
                description: description,
                type: type,
                storyPoint: storyPoint
            ),
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Update Task succès → id:", response.id)
        }
        
        return response
    }

    // Mise à jour du statut d’une tâche
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

        if AppConfig.version == .dev {
            print("Update Task Status → URL:", url)
            print("Task ID:", taskId)
            print("Status:", status.rawValue)
        }

        do {
            let response: TaskResponse = try await APIClient.shared.request(
                url: url,
                method: "PATCH",
                body: body,
                requiresAuth: true
            )

            if AppConfig.version == .dev {
                print("Update Task Status succès →", response.status)
            }
            
            return response

        } catch {
            if AppConfig.version == .dev {
                print("Update Task Status erreur →", error.localizedDescription)
            }
            
            throw error
        }
    }

    // Liste des tâches d’une user story
    func listTasks(
        userStoryId: Int,
        statut: String
    ) async throws -> [TaskListResponse] {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/userstories/\(userStoryId)/tasks/list/statut/\(statut)")

        if AppConfig.version == .dev {
            print("Tasks List → URL:", url)
        }

        let tasks: [TaskListResponse] = try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )

        if AppConfig.version == .dev {
            print("Tasks List succès → count:", tasks.count)
        }
        
        return tasks
    }

    // Récupère le détail d’une tâche
    func fetchTask(taskId: Int) async throws -> TaskResponse {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/detail/\(taskId)")

        if AppConfig.version == .dev {
            print("Task Detail → URL:", url)
        }

        return try await APIClient.shared.request(
            url: url,
            method: "GET",
            requiresAuth: true
        )
    }

    // Supprime une tâche
    func deleteTask(taskId: Int) async throws {

        let url = AppConfig.baseURL
            .appendingPathComponent("/api/tasks/delete/\(taskId)")

        if AppConfig.version == .dev {
            print("Delete Task → URL:", url)
        }

        _ = try await APIClient.shared.request(
            url: url,
            method: "DELETE",
            requiresAuth: true
        ) as EmptyResponse

        if AppConfig.version == .dev {
            print("Delete Task succès → id:", taskId)
        }
    }
}
