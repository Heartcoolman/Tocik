//
//  AIInsightCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  统一的AI洞察卡片组件
//

import SwiftUI

struct AIInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let suggestion: String?
    let gradient: LinearGradient
    let priority: InsightPriority
    var action: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    enum InsightPriority {
        case urgent, high, medium, low
        
        var color: Color {
            switch self {
            case .urgent: return .red
            case .high: return .orange
            case .medium: return .yellow
            case .low: return .green
            }
        }
        
        var label: String {
            switch self {
            case .urgent: return "紧急"
            case .high: return "重要"
            case .medium: return "中等"
            case .low: return "一般"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            // 顶部：图标 + 优先级标签
            HStack {
                ZStack {
                    Circle()
                        .fill(gradient.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(gradient)
                }
                
                Spacer()
                
                Text(priority.label)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(priority.color.opacity(0.2))
                    .foregroundColor(priority.color)
                    .clipShape(Capsule())
            }
            
            // 标题
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 描述
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 建议（如果有）
            if let suggestion = suggestion {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // 操作按钮（如果有）
            if let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("查看详情")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(gradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
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
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    AIInsightCard(
        icon: "brain.head.profile",
        title: "学习效率下降",
        description: "过去3天的平均专注度下降了15%，可能是因为睡眠不足或任务过多。",
        suggestion: "建议减少每天的番茄钟数量，增加休息时间",
        gradient: Theme.primaryGradient,
        priority: .high,
        action: { print("查看详情") }
    )
    .padding()
}

