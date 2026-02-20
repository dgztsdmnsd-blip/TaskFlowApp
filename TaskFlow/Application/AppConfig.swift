//
//  AppConfig.swift
//  TaskFlow
//
//  Created by luc banchetti on 22/01/2026.
//
//  Ce fichier centralise :
//  - l’état global de navigation (AppState)
//  - la configuration d’environnement (dev / prod)
//  - des helpers utilitaires (Color, View, String)
//  - des constantes UI
//

import Foundation
import Combine
import SwiftUI

// AppState
// Gère le flux de navigation principal de l’application
@MainActor
final class AppState: ObservableObject {

    // États possibles de navigation
    enum Flow {
        case welcome     // Page de logo
        case loginHome   // Écran d’entrée connexion
        case loginForm   // Formulaire de login
        case main        // Application principale
    }

    // Flow courant
    @Published var flow: Flow

    init(flow: Flow = .welcome) {
        self.flow = flow
    }
}


// Version
// Type d’environnement applicatif
enum Version {
    case dev
    case prod
}


//  Statuts & Profils Admin
enum AdminUserStatus: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

enum AdminUserProfil: String {
    case util = "UTIL"
    case mgr = "MGR"
}


// Statuts User Stories
enum UserStoriesStatus: String {
    case aVenir = "NS"
    case enCours = "ENC"
    case termine = "TER"
}


//  Configuration App
enum AppConfig {

    // Version active de l’application
    static let version: Version = .dev

    // URL de base selon l’environnement
    static var baseURL: URL {
        switch version {
        case .dev:
            return URL(string: "http://127.0.0.1:8000")!
        case .prod:
            return URL(string: "https://lucban.alwaysdata.net")!
        }
    }
}


// Color Helpers
extension Color {

    // Initialise une couleur depuis une chaîne hexadécimale
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }

    // Convertit une couleur en hex (#RRGGBB)
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


// Modes UI
// Mode d’affichage d’un détail de User Story
enum UserStoryDetailMode {
    case readOnly
    case edit
}


// View Helpers
extension View {

    // Applique une transformation conditionnelle
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


// Notifications globales
extension Notification.Name {

    static let userStoryDidChange =
        Notification.Name("userStoryDidChange")

    static let userStoryStatusDidChange =
        Notification.Name("userStoryStatusDidChange")

    static let projectListShouldRefresh =
        Notification.Name("projectListShouldRefresh")

    static let taskDidChange =
        Notification.Name("taskDidChange")

    static let tagsDidChange =
        Notification.Name("tagsDidChange")
}


// String Helpers
extension String {

    // Convertit une chaîne en Date
    // Supporte ISO8601 + yyyy-MM-dd
    func toDateOnly() -> Date? {

        // ISO8601 complet (avec millisecondes)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: self) {
            return date
        }

        // ISO8601 standard
        isoFormatter.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter.date(from: self) {
            return date
        }

        // Format yyyy-MM-dd
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(from: self)
    }
}


// Navigation Title
extension View {
    // Style de titre de navigation personnalisé
    func appNavigationTitle(_ title: String) -> some View {
        modifier(AppNavigationTitle(title: title))
    }
}


//  Taille adaptative des cards
enum UIConstants {

    static let cardHeight: CGFloat = 160

    static let cardWidthCompact: CGFloat = 180   // iPhone
    static let cardWidthRegular: CGFloat = 240   // iPad

    // Taille adaptative selon size class
    static func cardSize(for sizeClass: UserInterfaceSizeClass?) -> CGSize {
        CGSize(
            width: sizeClass == .regular
                ? cardWidthRegular
                : cardWidthCompact,
            height: cardHeight
        )
    }
}


// Adaptive Text Color
// Force blanc / noir selon Light / Dark Mode
extension View {
    func adaptiveTextColor() -> some View {
        modifier(AdaptiveTextColorModifier())
    }
}

private struct AdaptiveTextColorModifier: ViewModifier {

    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.foregroundStyle(
            scheme == .dark ? Color.white : Color.black
        )
    }
}
