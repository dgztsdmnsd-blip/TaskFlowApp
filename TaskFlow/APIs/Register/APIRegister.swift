//
//  APIRegister.swift
//  TaskFlow
//
//  Created by luc banchetti on 26/01/2026.
//
//  Modèle représentant la réponse API de l'inscription d'un utilisateur.
//  Ce fichier contient :
//  - la structure décodable de l'utilisateur
//

import Foundation

// Structure de réponse de Register
struct RegisterResponse: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let status: String
    let profil: String
}
