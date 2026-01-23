//
//  AppConfig.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    enum Flow {
        case welcome
        case login
        case main
    }

    @Published var flow: Flow = .welcome
}


enum Version {
    case dev
    case prod
}

enum AppConfig {

    static let version: Version = .dev

    static var baseURL: URL {
        switch version {
        case .dev:
            return URL(string: "http://127.0.0.1:8000")!
        case .prod:
            return URL(string: "//https://lucban.alwaysdata.net")!
        }
    }
}
