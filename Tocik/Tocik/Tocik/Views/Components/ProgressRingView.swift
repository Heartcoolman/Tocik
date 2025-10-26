//
//  ProgressRingView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 进度环组件（Apple Watch风格）
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double  // 0.0 to 1.0
    let gradient: LinearGradient
    let lineWidth: CGFloat
    let size: CGFloat
    let showGlow: Bool
    
    init(
        progress: Double,
        gradient: LinearGradient,
        lineWidth: CGFloat = 20,
        size: CGFloat = 200,
        showGlow: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.gradient = gradient
        self.lineWidth = lineWidth
        self.size = size
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1, dampingFraction: 0.8), value: progress)
            
            // 发光效果
            if showGlow && progress > 0 {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        gradient,
                        style: StrokeStyle(
                            lineWidth: lineWidth / 2,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 8)
                    .opacity(0.6)
            }
            
            // 进度端点
            if progress > 0 && progress < 1 {
                Circle()
                    .fill(.white)
                    .frame(width: lineWidth * 0.8, height: lineWidth * 0.8)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(progress * 360 - 90))
            }
        }
        .frame(width: size, height: size)
    }
}

// 多重进度环（Apple Watch风格）
struct MultiProgressRingView: View {
    struct RingData {
        let progress: Double
        let gradient: LinearGradient
        let label: String
    }
    
    let rings: [RingData]
    let size: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(Array(rings.enumerated()), id: \.offset) { index, ring in
                let ringSize = size - CGFloat(index) * (size / CGFloat(rings.count + 1))
                ProgressRingView(
                    progress: ring.progress,
                    gradient: ring.gradient,
                    lineWidth: 12,
                    size: ringSize,
                    showGlow: false
                )
            }
        }
        .frame(width: size, height: size)
    }
}

