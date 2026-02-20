//
//  ViewLogger.swift
//  TaskFlow
//
//  Created by luc banchetti on 16/02/2026.
//
//  Extension utilitaire permettant de tracer
//  le cycle de vie des vues SwiftUI.
//

import SwiftUI

extension View {

    // Log simple des événements d’apparition / disparition
    func logLifecycle(_ name: String) -> some View {
        self

            // Appelé lorsque la vue apparaît à l’écran
            .onAppear {
                if AppConfig.version == .dev {
                    print("\(name) – onAppear")
                }
            }

            // Appelé lorsque la vue disparaît
            .onDisappear {
                if AppConfig.version == .dev {
                    print("\(name) – onDisappear")
                }
            }
    }
}
