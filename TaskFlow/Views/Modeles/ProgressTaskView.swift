//
//  ProgressTaskView.swift
//  TaskFlow
//
//  Created by luc banchetti on 11/02/2026.
//

import SwiftUI

struct ProgressTaskView: View {
    var progression: Double
    
    private var progressColor: Color {
        switch progression {
        case 0..<0.3: return .red
        case 0.3..<0.7: return .orange
        default: return .green
        }
    }
    
    var body: some View {
        ProgressView(value: progression)
            .tint(progressColor)
        
        Text("\(Int(progression * 100)) % terminé")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

#Preview {
    ProgressTaskView(progression: 0.5)
}
