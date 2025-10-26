//
//  SuggestionRanker.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 智能建议排序器（优化14）
//

import Foundation

/// 建议优先级排序 - 根据多维度动态评分
class SuggestionRanker {
    
    /// 智能排序建议
    static func rank(
        suggestions: [SmartSuggestion],
        context: RankingContext
    ) -> [SmartSuggestion] {
        return suggestions.map { suggestion in
            let mutableSuggestion = suggestion
            mutableSuggestion.dynamicScore = calculateScore(
                for: suggestion,
                context: context
            )
            return mutableSuggestion
        }.sorted { $0.dynamicScore > $1.dynamicScore }
    }
    
    /// 计算动态评分
    private static func calculateScore(
        for suggestion: SmartSuggestion,
        context: RankingContext
    ) -> Double {
        var score = 0.0
        
        // 基础优先级 (0-30分)
        score += Double(suggestion.priority.rawValue) * 10
        
        // 时效性加分 (0-20分)
        if isUrgent(suggestion, given: context.upcomingDeadlines) {
            score += 20
        } else if isTimeSensitive(suggestion) {
            score += 10
        }
        
        // 可行性加分 (0-15分)
        if isActionable(suggestion, given: context.currentSchedule) {
            score += 15
        } else if isPractical(suggestion) {
            score += 8
        }
        
        // 历史接受度加分 (0-15分)
        let acceptanceRate = context.historicalAcceptance[suggestion.suggestionType] ?? 0.5
        score += acceptanceRate * 15
        
        // 预期影响力加分 (0-10分)
        score += estimateImpact(suggestion) * 10
        
        // AI置信度加分 (0-10分)
        score += (suggestion.aiConfidence ?? 0.5) * 10
        
        // 新鲜度（避免重复建议）(-10分)
        if context.recentSuggestions.contains(where: { isSimilar($0, suggestion) }) {
            score -= 10
        }
        
        return score
    }
    
    // MARK: - 评估方法
    
    private static func isUrgent(_ suggestion: SmartSuggestion, given deadlines: [Date]) -> Bool {
        // 检查建议内容是否与临近截止日期相关
        let content = suggestion.content.lowercased()
        for deadline in deadlines where Date().distance(to: deadline) < 86400 * 3 { // 3天内
            if content.contains("考试") || content.contains("截止") {
                return true
            }
        }
        return false
    }
    
    private static func isTimeSensitive(_ suggestion: SmartSuggestion) -> Bool {
        let content = suggestion.content.lowercased()
        return content.contains("今日") || content.contains("今天") || content.contains("马上")
    }
    
    private static func isActionable(_ suggestion: SmartSuggestion, given schedule: [TimeSlot]) -> Bool {
        // 简化：检查建议是否包含具体行动
        let content = suggestion.content.lowercased()
        let actionWords = ["建议", "推荐", "可以", "尝试", "开始"]
        return actionWords.contains(where: { content.contains($0) })
    }
    
    private static func isPractical(_ suggestion: SmartSuggestion) -> Bool {
        // 检查是否包含具体数字和时间
        let content = suggestion.content
        return content.contains(where: { $0.isNumber }) || content.contains("分钟") || content.contains("小时")
    }
    
    private static func estimateImpact(_ suggestion: SmartSuggestion) -> Double {
        // 根据建议类型估计影响力
        switch suggestion.suggestionType {
        case .efficiency: return 0.9
        case .habitImprovement: return 0.7
        case .studyPlan: return 0.8
        case .goalSetting: return 0.7
        case .review: return 0.8
        case .timeManagement: return 0.85
        case .warning: return 0.95
        }
    }
    
    private static func isSimilar(_ s1: SmartSuggestion, _ s2: SmartSuggestion) -> Bool {
        // 简单相似度检测
        return s1.title == s2.title || s1.content.hasPrefix(String(s2.content.prefix(20)))
    }
}

// MARK: - 排序上下文

struct RankingContext {
    let upcomingDeadlines: [Date]
    let currentSchedule: [TimeSlot]
    let historicalAcceptance: [SmartSuggestion.SuggestionType: Double]
    let recentSuggestions: [SmartSuggestion]
}

struct TimeSlot {
    let start: Date
    let end: Date
    let isBusy: Bool
}

// MARK: - SmartSuggestion 扩展

extension SmartSuggestion {
    var dynamicScore: Double {
        get { return 0.0 } // 临时默认值
        set { } // 需要添加存储属性
    }
}

