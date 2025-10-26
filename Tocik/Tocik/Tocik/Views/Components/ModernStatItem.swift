//
//  ModernStatItem.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct ModernStatItem: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(gradient)
                .symbolRenderingMode(.hierarchical)
            
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(gradient)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    HStack {
        ModernStatItem(
            title: "今日完成",
            value: "8",
            icon: "checkmark.circle.fill",
            gradient: Theme.statsGradient
        )
        
        ModernStatItem(
            title: "本周完成",
            value: "42",
            icon: "chart.bar.fill",
            gradient: Theme.primaryGradient
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

