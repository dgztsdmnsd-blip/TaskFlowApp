//
//  APIMessageResponse.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//
//  Modèle générique utilisé pour décoder
//  les réponses simples de l’API.
//  Contient :
//  - Un message (succès / info / erreur)
//  - Un token optionnel (ex: login)
//

import Foundation

// Réponse API générique avec message et token optionnel
struct APIMessageResponse: Decodable {
    
    // Message retourné par le backend
    let message: String
    
    // Token optionnel (authentification, refresh, etc.)
    let token: String?
}
