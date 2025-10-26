//
//  AIWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - AI建议小部件卡片
//

import SwiftUI
import SwiftData

struct AIWidgetCard: View {
    @Query private var suggestions: [SmartSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "brain")
                    .foregroundStyle(Theme.primaryGradient)
                Text("AI建议")
                    .font(.headline)
                
                Spacer()
                
                if unreadCount > 0 {
                    Text("\(unreadCount)条")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .clipShape(Capsule())
                }
            }
            
            // 最新建议
            if let latestSuggestion = latestActiveSuggestion {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: priorityIcon(latestSuggestion.priority))
                            .font(.caption)
                            .foregroundColor(Color(hex: latestSuggestion.priorityColor))
                        
                        Text(latestSuggestion.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                    }
                    
                    Text(latestSuggestion.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding(12)
                .background(Color(hex: latestSuggestion.priorityColor).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("暂无新建议")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var activeSuggestions: [SmartSuggestion] {
        suggestions.filter { !$0.isRead && !($0.expiryDate ?? Date.distantFuture < Date()) }
    }
    
    private var unreadCount: Int {
        activeSuggestions.count
    }
    
    private var latestActiveSuggestion: SmartSuggestion? {
        activeSuggestions.sorted { $0.priority.rawValue > $1.priority.rawValue }.first
    }
    
    private func priorityIcon(_ priority: SmartSuggestion.Priority) -> String {
        switch priority {
        case .high: return "exclamationmark.circle.fill"
        case .medium: return "lightbulb.fill"
        case .low: return "info.circle.fill"
        }
    }
}

