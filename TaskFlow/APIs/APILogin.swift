//
//  APIToken.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation

struct APIToken: Decodable {
    var token: String
    var refresh_Token: String
}
