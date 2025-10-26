//
//  FloatingActionMenu.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  悬浮快捷菜单
//

import SwiftUI
import SwiftData

struct FloatingActionMenu: View {
    @State private var isExpanded = false
    @State private var showAddNote = false
    @State private var showAddTodo = false
    @State private var showAddFlashCard = false
    @State private var showAddWrongQuestion = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // 展开的菜单项（从下往上，移除番茄钟）
            if isExpanded {
                QuickActionButton(icon: "exclamationmark.triangle.fill", label: "错题", color: Color(hex: "#FF6B6B")) {
                    closeMenuAndShow { showAddWrongQuestion = true }
                }
                
                QuickActionButton(icon: "rectangle.stack.fill", label: "闪卡", color: Color(hex: "#4A90E2")) {
                    closeMenuAndShow { showAddFlashCard = true }
                }
                
                QuickActionButton(icon: "checklist", label: "待办", color: Theme.todoColor) {
                    closeMenuAndShow { showAddTodo = true }
                }
                
                QuickActionButton(icon: "note.text", label: "笔记", color: Theme.noteColor) {
                    closeMenuAndShow { showAddNote = true }
                }
            }
            
            // 主按钮
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                    HapticManager.shared.light()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Theme.primaryGradient)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .rotationEffect(.degrees(isExpanded ? 135 : 0))
            }
        }
        .sheet(isPresented: $showAddNote) {
            EditNoteView(note: nil)
        }
        .sheet(isPresented: $showAddTodo) {
            AddTodoView()
        }
        .sheet(isPresented: $showAddFlashCard) {
            AddFlashDeckView()
        }
        .sheet(isPresented: $showAddWrongQuestion) {
            AddWrongQuestionView()
        }
    }
    
    private func closeMenuAndShow(action: @escaping () -> Void) {
        withAnimation {
            isExpanded = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
