//
//  QuickToolsBar.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  工具快捷栏
//

import SwiftUI
import SwiftData

struct QuickToolsBar: View {
    @Binding var selectedTool: ToolItem?
    @Query private var notes: [Note]
    @Query private var flashCards: [FlashCard]
    @Query private var wrongQuestions: [WrongQuestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习工具")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ToolQuickButton(label: "笔记", icon: "note.text", count: notes.count, color: Theme.noteColor, toolId: "note", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "闪卡", icon: "rectangle.stack.fill", count: flashCards.count, color: Color(hex: "#4A90E2"), toolId: "flashcard", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "错题", icon: "exclamationmark.triangle.fill", count: wrongQuestions.count, color: Color(hex: "#FF6B6B"), toolId: "wrong-question", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "复习计划", icon: "arrow.triangle.2.circlepath", count: nil, color: Color(hex: "#A78BFA"), toolId: "review-planner", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "答疑助手", icon: "questionmark.bubble.fill", count: nil, color: Color(hex: "#8B5CF6"), toolId: "qa-assistant", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "知识图谱", icon: "network", count: nil, color: Color(hex: "#4ECDC4"), toolId: "knowledge-map", selectedTool: $selectedTool)
                    
                    ToolQuickButton(label: "学习日志", icon: "book.pages.fill", count: nil, color: Color(hex: "#FBBF24"), toolId: "study-journal", selectedTool: $selectedTool)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct ToolQuickButton: View {
    let label: String
    let icon: String
    let count: Int?
    let color: Color
    let toolId: String
    @Binding var selectedTool: ToolItem?
    
    var body: some View {
        Button(action: {
            selectedTool = ToolRegistry.tool(for: toolId)
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    if let count = count, count > 0 {
                        Text("\(count)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(4)
                            .background(.red)
                            .clipShape(Circle())
                            .offset(x: 20, y: -20)
                    }
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }
}
