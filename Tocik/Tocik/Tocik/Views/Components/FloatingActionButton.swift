//
//  FloatingActionButton.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 浮动操作按钮
//

import SwiftUI

struct FloatingActionButton: View {
    @State private var isExpanded = false
    
    let actions: [FABAction] = [
        FABAction(icon: "plus", title: "添加待办", color: Theme.todoColor),
        FABAction(icon: "timer", title: "开始番茄钟", color: Theme.pomodoroColor),
        FABAction(icon: "note.text.badge.plus", title: "快速笔记", color: Theme.noteColor),
        FABAction(icon: "star.circle", title: "习惯打卡", color: Theme.habitColor),
    ]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 展开的操作按钮
            if isExpanded {
                VStack(spacing: 16) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                        FABActionButton(action: action)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3).delay(Double(index) * 0.05), value: isExpanded)
                    }
                }
                .padding(.bottom, 80)
            }
            
            // 主按钮
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.light()
            }) {
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    
                    Image(systemName: isExpanded ? "xmark" : "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 135 : 0))
                }
            }
        }
        .padding(24)
    }
}

struct FABAction {
    let icon: String
    let title: String
    let color: Color
}

struct FABActionButton: View {
    let action: FABAction
    
    var body: some View {
        HStack(spacing: 12) {
            Text(action.title)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThickMaterial)
                .clipShape(Capsule())
            
            ZStack {
                Circle()
                    .fill(action.color)
                    .frame(width: 48, height: 48)
                    .shadow(color: action.color.opacity(0.4), radius: 8, y: 4)
                
                Image(systemName: action.icon)
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
    }
}

