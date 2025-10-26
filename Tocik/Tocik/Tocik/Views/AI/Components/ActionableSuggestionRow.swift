//
//  ActionableSuggestionRow.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  可操作建议的行式布局
//

import SwiftUI

struct ActionableSuggestionRow: View {
    let suggestion: SmartSuggestion
    let onFeedback: ((SuggestionFeedback.FeedbackAction) -> Void)?
    
    @State private var isExpanded = false
    
    private var priorityColor: Color {
        switch suggestion.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧优先级指示条
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 8) {
                // 顶部行：标题 + AI标签
                HStack {
                    Text(cleanTitle)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    if suggestion.isAIGenerated {
                        Text("✨ AI")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primaryColor.opacity(0.3), Theme.primaryColor.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(Theme.primaryColor)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // 展开/折叠按钮
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 内容（可折叠）
                if isExpanded {
                    Text(cleanContent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // 操作按钮（仅未反馈时显示）
                if suggestion.userFeedback == nil {
                    HStack(spacing: 8) {
                        ActionButton(
                            icon: "hand.thumbsup",
                            label: "有帮助",
                            color: .green
                        ) {
                            onFeedback?(.helpful)
                            HapticManager.shared.success()
                        }
                        
                        ActionButton(
                            icon: "hand.thumbsdown",
                            label: "无帮助",
                            color: .red
                        ) {
                            onFeedback?(.notHelpful)
                            HapticManager.shared.light()
                        }
                        
                        if suggestion.actionType != nil {
                            ActionButton(
                                icon: "checkmark.circle.fill",
                                label: "执行",
                                color: Theme.primaryColor
                            ) {
                                onFeedback?(.implemented)
                                HapticManager.shared.success()
                            }
                        }
                    }
                } else {
                    // 已反馈状态
                    HStack(spacing: 6) {
                        Image(systemName: suggestion.userFeedback == "有帮助" ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundColor(suggestion.userFeedback == "有帮助" ? .green : .gray)
                            .font(.caption)
                        
                        Text("已反馈：\(suggestion.userFeedback ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(suggestion.userFeedback != nil ? Color.gray.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var cleanTitle: String {
        suggestion.title.replacingOccurrences(of: "**", with: "")
    }
    
    private var cleanContent: String {
        suggestion.content.replacingOccurrences(of: "**", with: "")
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ActionableSuggestionRow(
            suggestion: SmartSuggestion(
                suggestionType: .efficiency,
                title: "建议调整学习时段",
                content: "您在早晨的专注度最高，建议将重要任务安排在这个时段。",
                priority: .high,
                isAIGenerated: true,
                aiConfidence: 0.85
            ),
            onFeedback: { _ in }
        )
        
        ActionableSuggestionRow(
            suggestion: SmartSuggestion(
                suggestionType: .habitImprovement,
                title: "坚持晨间学习习惯",
                content: "您已连续7天早起学习，继续保持！",
                priority: .medium,
                isAIGenerated: false,
                aiConfidence: 0
            ),
            onFeedback: { _ in }
        )
    }
    .padding()
}

