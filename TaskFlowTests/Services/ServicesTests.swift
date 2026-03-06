//
//  ServicesTests.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/03/2026.
//

import Testing
import Foundation
@testable import TaskFlow

@Suite(.serialized)
@MainActor
struct ServicesTests {
    
    // Promotion via Admin
    @Test
    func admin_promotes() async throws {
        SessionManager.shared.clear()
        #expect(SessionManager.shared.getAccessToken() == nil)
      
        // Login admin
        let adminLogin = try await LoginService.shared.login(
            email: "admin@taskflow.com",
            password: "PassTemp123!"
        )
        #expect(!adminLogin.token.isEmpty)
        
        SessionManager.shared.saveAccessToken(adminLogin.token)

        #expect(SessionManager.shared.getAccessToken() != nil)

        // Recherche de l'utilisateur à promouvoir
        let users = try await UsersListService.shared.fetchUsers()

        guard let target = users.first(where: { $0.email == "testuser@taskflow.com" }) else {
            Issue.record("Utilisateur testuser@taskflow.com introuvable dans /api/users/liste")
            return
        }

        if SessionManager.shared.getAccessToken()?.isEmpty ?? true {
            SessionManager.shared.saveAccessToken(adminLogin.token)
        }
        
        // Promotion -> MGR
        let promoted = try await UserAdminService.shared.updateUser(
            id: target.id,
            profil: .mgr
        )
        #expect(promoted.profil == AdminUserProfil.mgr.rawValue)
        
        if SessionManager.shared.getAccessToken()?.isEmpty ?? true {
            SessionManager.shared.saveAccessToken(adminLogin.token)
        }
        
        // Retour -> UTIL
        let retour = try await UserAdminService.shared.updateUser(
            id: target.id,
            profil: .util
        )
        #expect(retour.profil == AdminUserProfil.util.rawValue)

        if SessionManager.shared.getAccessToken()?.isEmpty ?? true {
            SessionManager.shared.saveAccessToken(adminLogin.token)
        }
        
        // Disable
        let disabled = try await UserAdminService.shared.updateUser(
            id: target.id,
            status: .inactive
        )
        #expect(disabled.status == AdminUserStatus.inactive.rawValue)
        
        if SessionManager.shared.getAccessToken()?.isEmpty ?? true {
            SessionManager.shared.saveAccessToken(adminLogin.token)
        }
        
        // Enable
        let enabled = try await UserAdminService.shared.updateUser(
            id: target.id,
            status: .active
        )
        #expect(enabled.status == AdminUserStatus.active.rawValue)
        
        SessionManager.shared.clear()
        #expect(SessionManager.shared.getAccessToken() == nil)
    }

    // Création d'un projet complet
    @Test
    func whole_flow() async throws {

        // Deconnexion
        SessionManager.shared.clear()

        // Login
        let login = try await LoginService.shared.login(
            email: "banchetti.luc@gmail.com",
            password: "PassTemp123!"
        )

        SessionManager.shared.saveAccessToken(login.token)

        // Nom unique
        let unique = UUID().uuidString.prefix(5)

        // Création de projet
        let project = try await ProjectService.shared.createProject(
            title: "Projet \(unique)",
            description: "Description"
        )

        #expect(project.title.contains(unique))
        
        // Maj projet
        let projectmaj = try await ProjectService.shared.updateProjectStatus(
            id: project.id,
            status: .inProgress
        )
        
        #expect(projectmaj.status == .inProgress)
        
        // Ajout d'un membre
        let users = try await UsersListService.shared.fetchUsers()

        guard let target = users.first(where: { $0.email == "testuser@taskflow.com" }) else {
            Issue.record("Utilisateur testuser@taskflow.com introuvable dans /api/users/liste")
            return
        }
        
        
        let projectUsersVM = ProjectUsersViewModel(projectId: project.id)
        await projectUsersVM.addMember(
            userId: target.id
        )
        
        await projectUsersVM.fetchMembers()

        #expect(projectUsersVM.members.contains(where: { $0.id == target.id }))
        
        // Maj desc projet
        let projectmajdesc = try await ProjectService.shared.updateProject(
            id: project.id,
            title: "Projet \(unique)",
            description: "Description mise à jour"
        )
        
        #expect(projectmajdesc.description == "Description mise à jour")
            

        // Création de user story
        let userStory = try await StoriesService.shared.createUserStory(
            projectId: project.id,
            title: "US \(unique)",
            description: "Description",
            couleur: "#FF5733"
        )

        #expect(userStory.title.contains(unique))
        
        // Maj de la user story
        let userStorymaj = try await StoriesService.shared.updateStoryStatus(
            userStoryId: userStory.id,
            status: .inProgress
        )
        
        #expect(userStorymaj.status == .inProgress)
        
        // Maj desc user story
        let userStorymajdesc = try await StoriesService.shared.updateUserStory(
            userStoryId: userStory.id,
            description: "Description mise à jour"
        )
        
        #expect(userStorymajdesc.description == "Description mise à jour")
            

        // Création d'une tâche
        let task = try await TaskService.shared.createTask(
            userStoryId: userStory.id,
            title: "Task \(unique)",
            description: "Description",
            type: "Test"
        )

        #expect(task.title.contains(unique))
        
        // Mise à jour de la tâche
        let taskmaj = try await TaskService.shared.updateTaskStatus(taskId: task.id, status: .inProgress)
        
        #expect(taskmaj.status == .inProgress)
        
        
        // Maj desc tâche
        let taskmajdesc = try await TaskService.shared.updateTask(
            taskId: task.id,
            description: "Description mise à jour"
        )
        
        #expect(taskmajdesc.description == "Description mise à jour")

        // Création d'un tag
        let tag = try await TagsService.shared.createTag(
            tagName: "Tag \(unique)",
            couleur: "#FF5733"
        )

        #expect(tag.tagName.lowercased().contains(unique.lowercased()))
        
        // Affectation du tag
        let taggedTask = try await TagsService.shared.attachTag(
            tagId: tag.id,
            toStory: userStory.id)
        
        #expect(taggedTask.tags.contains(where: { $0.id == tag.id }))
        
        // Recherche par tag
        let impact = try await TagsService.shared.fetchTagImpact(
            tagId: tag.id
        )
        
        #expect(impact.userStories.contains(where: { $0.id == userStory.id }))

        
        // Detachement du tag
        try await TagsService.shared.detachTag(
            tagId: tag.id,
            fromStory: userStory.id)
        
        // Recherche par tag
        let impactvide = try await TagsService.shared.fetchTagImpact(
            tagId: tag.id
        )
        
        #expect(!impactvide.userStories.contains(where: { $0.id == userStory.id }))
        
        // Suppression du tag
        try await TagsService.shared.deleteTag(tagId: tag.id)
        
        let taglist = try await TagsService.shared.listTags()
        
        #expect(!taglist.contains(where: { $0.id == tag.id }))
        
        // Suppression de la tâche
        try await TaskService.shared.deleteTask(taskId: task.id)
        
        let tasklist = try await TaskService.shared.listTasks(
            userStoryId: userStory.id,
            statut: "ENC"
        )
        
        #expect(!tasklist.contains(where: { $0.id == task.id }))
        
        // suppression de la user story
        try await StoriesService.shared.deleteStory(userStoryId: userStory.id)
        
        let uslist = try await StoriesService.shared.listAllUserStories(
            projectId: project.id,
            statut: .notStarted)
        
        #expect(!uslist.contains(where: { $0.id == userStory.id }))
        
        // Retrait du membre
        await projectUsersVM.removeMember(
            userId: target.id
        )
        
        await projectUsersVM.fetchMembers()

        #expect(!projectUsersVM.members.contains(where: { $0.id == target.id }))
        
        // suppression du projet
        try await ProjectService.shared.deleteProject(id: project.id)
        
        let prolist = try await ProjectService.shared.listActiveProjects()
        
        #expect(!prolist.contains(where: { $0.id == project.id }))
        
        // Deconnexion
        SessionManager.shared.clear()
    }
}
