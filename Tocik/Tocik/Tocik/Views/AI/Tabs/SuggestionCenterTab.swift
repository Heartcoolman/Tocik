//
//  SuggestionCenterTab.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  建议中心标签页
//

import SwiftUI

struct SuggestionCenterTab: View {
    let suggestions: [SmartSuggestion]
    let recommendations: [RecommendedAction]
    let onSuggestionFeedback: ((SmartSuggestion, SuggestionFeedback.FeedbackAction) -> Void)?
    let onAcceptRecommendation: ((RecommendedAction) -> Void)?
    let onRejectRecommendation: ((RecommendedAction) -> Void)?
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var filterPriority: SmartSuggestion.Priority? = nil
    @State private var showFilterMenu = false
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: Theme.spacing.medium), count: count)
    }
    
    private var filteredSuggestions: [SmartSuggestion] {
        let activeSuggestions = suggestions.filter { !($0.expiryDate ?? Date.distantFuture < Date()) }
        if let priority = filterPriority {
            return activeSuggestions.filter { $0.priority == priority }
        }
        return activeSuggestions.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 筛选工具栏
                FilterToolbar(
                    selectedPriority: $filterPriority,
                    suggestionCount: suggestions.count,
                    recommendationCount: recommendations.count
                )
                
                // AI推荐行动（高优先级展示）
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                        Text("🎯 AI智能推荐")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: Theme.spacing.medium) {
                            ForEach(recommendations) { recommendation in
                                ModernRecommendationCard(
                                    recommendation: recommendation,
                                    onAccept: { onAcceptRecommendation?(recommendation) },
                                    onReject: { onRejectRecommendation?(recommendation) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // AI智能建议
                if !filteredSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                        Text("💡 智能建议")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(filteredSuggestions) { suggestion in
                                ActionableSuggestionRow(
                                    suggestion: suggestion,
                                    onFeedback: { action in
                                        onSuggestionFeedback?(suggestion, action)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 空状态
                if filteredSuggestions.isEmpty && recommendations.isEmpty {
                    EmptySuggestionsView()
                }
            }
            .padding(.vertical)
        }
    }
}

// 筛选工具栏
struct FilterToolbar: View {
    @Binding var selectedPriority: SmartSuggestion.Priority?
    let suggestionCount: Int
    let recommendationCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // 统计信息
            HStack(spacing: 16) {
                StatChip(icon: "lightbulb.fill", count: suggestionCount, label: "建议", color: .blue)
                StatChip(icon: "star.fill", count: recommendationCount, label: "推荐", color: .purple)
            }
            
            // 优先级筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "全部",
                        isSelected: selectedPriority == nil,
                        action: { selectedPriority = nil }
                    )
                    
                    FilterChip(
                        title: "高优先级",
                        isSelected: selectedPriority == .high,
                        color: .red,
                        action: { selectedPriority = .high }
                    )
                    
                    FilterChip(
                        title: "中优先级",
                        isSelected: selectedPriority == .medium,
                        color: .orange,
                        action: { selectedPriority = .medium }
                    )
                    
                    FilterChip(
                        title: "低优先级",
                        isSelected: selectedPriority == .low,
                        color: .blue,
                        action: { selectedPriority = .low }
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

struct StatChip: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .font(.headline.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = Theme.primaryColor
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// 现代化推荐卡片
struct ModernRecommendationCard: View {
    @Bindable var recommendation: RecommendedAction
    let onAccept: () -> Void
    let onReject: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cleanTitle: String {
        recommendation.title.replacingOccurrences(of: "**", with: "")
    }
    
    private var cleanDescription: String {
        recommendation.actionDescription.replacingOccurrences(of: "**", with: "")
    }
    
    private var cleanReason: String {
        recommendation.reason.replacingOccurrences(of: "**", with: "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            // 顶部：图标 + 置信度环
            HStack {
                ZStack {
                    Circle()
                        .fill(typeGradient.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: typeIcon)
                        .font(.title)
                        .foregroundStyle(typeGradient)
                }
                
                Spacer()
                
                // 置信度环形进度
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: recommendation.aiConfidence)
                        .stroke(Theme.primaryGradient, lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(Int(recommendation.aiConfidence * 100))")
                            .font(.caption.bold())
                        Text("%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 标题和类型
            VStack(alignment: .leading, spacing: 4) {
                Text(cleanTitle)
                    .font(.headline)
                
                Text(recommendation.recommendationType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 描述
            Text(cleanDescription)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // 推荐理由
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                
                Text(cleanReason)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("接受")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(typeGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onReject) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("拒绝")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(typeGradient.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
    }
    
    private var typeIcon: String {
        switch recommendation.recommendationType {
        case .habit: return "star.circle.fill"
        case .goal: return "target"
        case .studyPlan: return "calendar.badge.clock"
        }
    }
    
    private var typeGradient: LinearGradient {
        switch recommendation.recommendationType {
        case .habit: return Theme.habitGradient
        case .goal: return LinearGradient(
            colors: [Color(hex: "#A78BFA"), Color(hex: "#8B5CF6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        case .studyPlan: return Theme.statsGradient
        }
    }
}

// 空状态视图
struct EmptySuggestionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.habitGradient)
            
            Text("太棒了！")
                .font(.title2.bold())
            
            Text("暂时没有新的建议\n继续保持良好的学习习惯")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    SuggestionCenterTab(
        suggestions: [
            SmartSuggestion(
                suggestionType: .efficiency,
                title: "调整学习时段",
                content: "早晨的专注度更高，建议重要任务安排在这个时段",
                priority: .high,
                isAIGenerated: true,
                aiConfidence: 0.85
            )
        ],
        recommendations: [
            RecommendedAction(
                recommendationType: .habit,
                title: "每日晨读30分钟",
                actionDescription: "养成每天早上6:30-7:00的英语学习习惯",
                reason: "您的数据显示早晨专注度最高，适合语言学习",
                configurationData: "{}",
                priority: 8,
                aiConfidence: 0.9
            )
        ],
        onSuggestionFeedback: { _, _ in },
        onAcceptRecommendation: { _ in },
        onRejectRecommendation: { _ in }
    )
}

