//
//  AnimatedGradientBackground.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 动画渐变背景
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animate = false
    @StateObject private var themeStore = ThemeStore.shared
    
    var body: some View {
        ZStack {
            // 基础背景色
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            // 动画渐变层
            ZStack {
                // 第一层渐变
                themeStore.currentTheme.primaryGradient
                    .opacity(0.15)
                    .blur(radius: 100)
                    .offset(x: animate ? 100 : -100, y: animate ? -50 : 50)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
                
                // 第二层渐变
                themeStore.currentTheme.secondaryGradient
                    .opacity(0.1)
                    .blur(radius: 80)
                    .offset(x: animate ? -80 : 80, y: animate ? 60 : -60)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animate = true
        }
    }
}

