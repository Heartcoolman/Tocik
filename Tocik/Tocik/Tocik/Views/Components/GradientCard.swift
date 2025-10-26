//
//  GradientCard.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content
    
    init(gradient: LinearGradient, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Theme.spacing.large)
            .frame(maxWidth: .infinity)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.05), radius: 40, x: 0, y: 20)
    }
}

#Preview {
    GradientCard(gradient: Theme.pomodoroGradient) {
        VStack {
            Text("渐变卡片")
                .font(Theme.titleFont)
                .foregroundColor(.white)
            Text("现代化设计")
                .foregroundColor(.white.opacity(0.9))
        }
    }
    .padding()
}

