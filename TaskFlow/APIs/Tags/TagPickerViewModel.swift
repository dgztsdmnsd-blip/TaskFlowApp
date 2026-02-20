//
//  TagPickerViewModel.swift
//  TaskFlow
//
//  Created by luc banchetti on 13/02/2026.
//
//  ViewModel gérant le chargement et l’état
//  du sélecteur de tags.
//  Gère les états : chargement, erreur, données.
//

import Foundation
import Combine

// ViewModel du sélecteur de tags
@MainActor
final class TagPickerViewModel: ObservableObject {

    // Liste des tags disponibles
    @Published var tags: [TagResponse] = []
    
    // Indique un chargement en cours
    @Published var isLoading = false
    
    // Message d’erreur éventuel
    @Published var errorMessage: String?

    // Charge les tags depuis l’API
    func loadTags() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Appel service
            tags = try await TagsService.shared.listTags()
            
        } catch {
            // Erreur générique
            errorMessage = "Impossible de charger les tags."
        }
    }
}
