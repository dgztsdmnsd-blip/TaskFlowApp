//
//  ViewLogger.swift
//  TaskFlow
//
//  Created by luc banchetti on 16/02/2026.
//

import SwiftUI

extension View {
    func logLifecycle() -> some View {
        let name = String(describing: Self.self)

        return self
            .onAppear {
                print("🟢 \(name) – onAppear")
            }
            .onDisappear {
                print("🔴 \(name) – onDisappear")
            }
    }
}
