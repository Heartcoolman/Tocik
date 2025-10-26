//
//  ModernOverviewCard.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct ModernOverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(gradient)
                .symbolRenderingMode(.hierarchical)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(gradient)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    ModernOverviewCard(
        title: "今日完成",
        value: "8",
        icon: "checkmark.circle.fill",
        gradient: Theme.statsGradient
    )
    .padding()
}

