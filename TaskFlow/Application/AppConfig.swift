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
import SwiftUI

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


enum UserStoriesStatus: String {
    case aVenir = "NS"
    case enCours = "ENC"
    case termine = "TER"
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }

        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}

extension Notification.Name {
    static let userStoryStatusDidChange =
        Notification.Name("userStoryStatusDidChange")
}

extension Notification.Name {
    static let userStoryDidChange =
        Notification.Name("userStoryDidChange")
}

extension String {
    func toDateOnly() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = .current
        return formatter.date(from: self)
    }
}

enum UserStoryDetailMode {
    case readOnly
    case edit
}
