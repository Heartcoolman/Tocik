//
//  UnlockCelebrationView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 成就解锁庆祝动画
//

import SwiftUI

struct UnlockCelebrationView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiCount = 0
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 24) {
                // 成就图标
                ZStack {
                    // 发光效果
                    Circle()
                        .fill(Color(hex: achievement.category.colorHex).opacity(0.3))
                        .frame(width: 150, height: 150)
                        .blur(radius: 30)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: achievement.category.colorHex), Color(hex: achievement.category.colorHex).opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Text(achievement.icon)
                        .font(.system(size: 60))
                }
                .scaleEffect(scale)
                .rotation3DEffect(
                    .degrees(scale == 1 ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                
                // 文字信息
                VStack(spacing: 8) {
                    Text("🎉 成就解锁！")
                        .font(.title3.bold())
                    
                    Text(achievement.name)
                        .font(.title.bold())
                    
                    Text(achievement.achievementDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // 奖励
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(achievement.rewardPoints) 积分")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.2))
                    .clipShape(Capsule())
                }
                .opacity(opacity)
                
                // 关闭按钮
                Button(action: dismiss) {
                    Text("太棒了！")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Theme.primaryGradient)
                        .clipShape(Capsule())
                }
                .opacity(opacity)
            }
            .padding(40)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: .black.opacity(0.3), radius: 30, y: 20)
            
            // 五彩纸屑效果
            ForEach(0..<20, id: \.self) { index in
                ConfettiPiece(delay: Double(index) * 0.1)
                    .opacity(confettiCount > index ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                opacity = 1.0
            }
            
            // 触发五彩纸屑
            for i in 0..<20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                    confettiCount = i + 1
                }
            }
            
            // 触觉反馈
            HapticManager.shared.pattern(.unlock)
        }
    }
    
    private func dismiss() {
        withAnimation {
            isShowing = false
        }
    }
}

struct ConfettiPiece: View {
    let delay: Double
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    let size: CGFloat = CGFloat.random(in: 8...15)
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                xOffset = CGFloat.random(in: -150...150)
                
                withAnimation(.easeIn(duration: 2).delay(delay)) {
                    yOffset = 800
                    rotation = Double.random(in: 360...720)
                }
            }
    }
}

