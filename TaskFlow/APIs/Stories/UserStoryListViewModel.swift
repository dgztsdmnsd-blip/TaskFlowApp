//
//  UserStoryListViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 09/02/2026.
//
//  ViewModel gérant le chargement et l’état
//  des listes de user stories.
//  Supporte :
//  - Stories du user connecté (owner)
//  - Toutes les stories du projet
//  - Gestion loading / erreurs
//

import Foundation
import Combine

// ViewModel de la liste des user stories
@MainActor
final class UserStoryListViewModel: ObservableObject {

    // Liste des user stories
    @Published var stories: [StoryResponse] = []
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    // Charge les user stories du user connecté (owner)
    func fetchStories(projectId: Int, statut: StoryStatus) async {

        isLoading = true
        errorMessage = nil

        if AppConfig.version == .dev {
            print("fetchStories → project:", projectId, "status:", statut.rawValue)
        }

        do {
            let fetchedStories = try await StoriesService.shared
                .listOwnerUserStory(projectId: projectId, statut: statut)

            if AppConfig.version == .dev {
                print("fetchStories → ids:", fetchedStories.map(\.id))
            }
            
            // Mise à jour UI
            stories = fetchedStories

        } catch APIError.httpError(let code, let message) {

            if AppConfig.version == .dev {
                print("fetchStories HTTP ERROR:", code, message ?? "")
            }
            
            errorMessage = message ?? "Erreur lors du chargement des user stories."

        } catch {

            // Ignore les cancellations SwiftUI normales
            if (error as NSError).code == NSURLErrorCancelled {
                if AppConfig.version == .dev {
                    print("fetchStories CANCELLED")
                }
                isLoading = false
                return
            }

            if AppConfig.version == .dev {
                print("fetchStories ERROR:", error.localizedDescription)
            }
            
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }

    // Charge toutes les user stories du projet
    func fetchAllStories(
        projectId: Int,
        statut: StoryStatus
    ) async {

        isLoading = true
        errorMessage = nil

        if AppConfig.version == .dev {
            print("fetchAllStories → project:", projectId, "status:", statut.rawValue)
        }

        do {
            let fetchedStories = try await StoriesService.shared
                .listAllUserStories(projectId: projectId, statut: statut)

            if AppConfig.version == .dev {
                print("fetchAllStories → ids:", fetchedStories.map(\.id))
            }

            // Mise à jour UI
            stories = fetchedStories

        } catch APIError.httpError(let code, let message) {

            if AppConfig.version == .dev {
                print("fetchAllStories HTTP ERROR:", code, message ?? "")
            }
            
            errorMessage = message ?? "Erreur lors du chargement des user stories."

        } catch {

            if AppConfig.version == .dev {
                print("fetchAllStories ERROR:", error.localizedDescription)
            }
            
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
