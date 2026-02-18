//
//  APIMessageResponse.swift
//  TaskFlow
//
//  Created by luc banchetti on 17/02/2026.
//

import Foundation

struct APIMessageResponse: Decodable {
    let message: String
    let token: String?
}
