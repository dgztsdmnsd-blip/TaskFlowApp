//
//  AppConfig.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Ce fichier centralise :
//  - l’état global de navigation de l’application (AppState)
//  - la configuration d’environnement (dev / prod)
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    enum Flow {
        case welcome
        case loginHome   // ConnexionView
        case loginForm   // LoginView
        case main
    }

    @Published var flow: Flow

    init(flow: Flow = .welcome) {
        self.flow = flow
    }
}

enum Version {
    case dev
    case prod
}

enum AdminUserStatus: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

enum AdminUserProfil: String {
    case util = "UTIL"
    case mgr = "MGR"
}

enum AppConfig {
    static let version: Version = .dev

    static var baseURL: URL {
        switch version {
        case .dev:
            return URL(string: "http://127.0.0.1:8000")!
        case .prod:
            return URL(string: "https://lucban.alwaysdata.net")!
        }
    }
}
