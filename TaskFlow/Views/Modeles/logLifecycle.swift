//
//  ViewLogger.swift
//  TaskFlow
//
//  Created by luc banchetti on 16/02/2026.
//

import SwiftUI

extension View {
    func logLifecycle(_ name: String) -> some View {
        self
            .onAppear {
                print("🟢 \(name) – onAppear")
            }
            .onDisappear {
                print("🔴 \(name) – onDisappear")
            }
    }
}
