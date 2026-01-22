//
//  AppConfig.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation

enum Environment {
    case dev
    case prod
}

enum AppConfig {

    static let environment: Environment = .dev

    static var baseURL: URL {
        switch environment {
        case .dev:
            return URL(string: "http://127.0.0.1:8000")!
        case .prod:
            return URL(string: "//https://lucban.alwaysdata.net")!
        }
    }
}
