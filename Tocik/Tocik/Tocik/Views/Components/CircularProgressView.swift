//
//  CircularProgressView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0-1
    let gradient: LinearGradient
    let lineWidth: CGFloat
    let showGlow: Bool
    
    init(
        progress: Double,
        gradient: LinearGradient = Theme.primaryGradient,
        lineWidth: CGFloat = 20,
        showGlow: Bool = false
    ) {
        self.progress = progress
        self.gradient = gradient
        self.lineWidth = lineWidth
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.springAnimation, value: progress)
            
            // 发光效果
            if showGlow {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        gradient,
                        style: StrokeStyle(lineWidth: lineWidth * 0.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 10)
                    .opacity(0.8)
            }
        }
    }
}

#Preview {
    CircularProgressView(
        progress: 0.7,
        gradient: Theme.pomodoroGradient,
        lineWidth: 24,
        showGlow: true
    )
    .frame(width: 200, height: 200)
    .padding()
}

