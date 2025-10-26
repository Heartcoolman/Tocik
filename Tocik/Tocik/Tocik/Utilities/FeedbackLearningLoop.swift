//
//  FeedbackLearningLoop.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - AI反馈学习循环（优化4）
//

import Foundation
import SwiftData

/// AI反馈学习循环 - AI建议质量持续提升
@MainActor
class FeedbackLearningLoop {
    static let shared = FeedbackLearningLoop()
    
    // 用户偏好模型
    private var preferenceModel = FeedbackPreferenceModel()
    
    /// 学习用户反馈
    func learn(from feedback: SuggestionFeedback) {
        // 更新偏好权重
        if let suggestionType = SmartSuggestion.SuggestionType(rawValue: feedback.suggestionType) {
            preferenceModel.update(
                suggestionType: suggestionType,
                action: feedback.action
            )
        }
        
        // 如果是拒绝，学习原因
        if feedback.action == .rejected, let reason = feedback.userComment {
            preferenceModel.learnRejectionPattern(reason: reason)
        }
        
        // 如果是接受或已执行，提升该类型权重
        if feedback.action == .accepted || feedback.action == .implemented {
            if let suggestionType = SmartSuggestion.SuggestionType(rawValue: feedback.suggestionType) {
                preferenceModel.boostType(suggestionType)
            }
        }
        
        print("🧠 反馈学习：\(feedback.action.rawValue) - 偏好已更新")
    }
    
    /// 增强AI Prompt（融入学习到的偏好）
    func enhancePrompt(_ basePrompt: String, userProfile: UserProfile?) -> String {
        let preferences = preferenceModel.generatePreferenceDescription()
        
        guard !preferences.isEmpty else {
            return basePrompt
        }
        
        let enhancedPrompt = """
        \(basePrompt)
        
        ## 🎯 用户偏好（基于历史反馈学习）
        \(preferences)
        
        请优先生成符合用户偏好的建议。
        """
        
        return enhancedPrompt
    }
    
    /// 过滤建议（基于学习到的偏好）
    func filterSuggestions(_ suggestions: [SmartSuggestion]) -> [SmartSuggestion] {
        return suggestions.filter { suggestion in
            preferenceModel.shouldInclude(suggestion)
        }
    }
    
    /// 获取偏好统计
    func getPreferenceStats() -> PreferenceStats {
        return preferenceModel.getStats()
    }
}

// MARK: - 偏好模型

class FeedbackPreferenceModel {
    // 各类型建议的权重
    private var typeWeights: [SmartSuggestion.SuggestionType: Double] = [
        .efficiency: 0.5,
        .habitImprovement: 0.5,
        .studyPlan: 0.5,
        .goalSetting: 0.5,
        .review: 0.5,
        .timeManagement: 0.5,
        .warning: 0.5
    ]
    
    // 拒绝原因统计
    private var rejectionPatterns: [String: Int] = [:]
    
    // 接受的建议特征
    private var acceptedPatterns: Set<String> = []
    
    /// 更新权重
    func update(suggestionType: SmartSuggestion.SuggestionType, action: SuggestionFeedback.FeedbackAction) {
        let currentWeight = typeWeights[suggestionType] ?? 0.5
        
        switch action {
        case .accepted, .helpful, .implemented:
            typeWeights[suggestionType] = min(currentWeight + 0.1, 1.0)
        case .rejected, .notHelpful:
            typeWeights[suggestionType] = max(currentWeight - 0.1, 0.1)
        case .deferred:
            // 延迟不影响权重
            break
        }
    }
    
    /// 学习拒绝模式
    func learnRejectionPattern(reason: String) {
        rejectionPatterns[reason, default: 0] += 1
    }
    
    /// 提升建议类型的权重
    func boostType(_ suggestionType: SmartSuggestion.SuggestionType) {
        let currentWeight = typeWeights[suggestionType] ?? 0.5
        typeWeights[suggestionType] = min(currentWeight + 0.15, 1.0)
    }
    
    /// 提升匹配模式的权重
    func boostPattern(matching suggestion: SmartSuggestion) {
        // 提取关键词
        let keywords = extractKeywords(from: suggestion.content)
        acceptedPatterns.formUnion(keywords)
    }
    
    /// 判断是否应包含该建议
    func shouldInclude(_ suggestion: SmartSuggestion) -> Bool {
        let weight = typeWeights[suggestion.suggestionType] ?? 0.5
        
        // 权重过低，过滤掉
        if weight < 0.3 {
            return false
        }
        
        // 检查是否匹配拒绝模式
        for (pattern, count) in rejectionPatterns where count >= 3 {
            if suggestion.content.lowercased().contains(pattern.lowercased()) {
                return false // 用户多次拒绝此类建议
            }
        }
        
        return true
    }
    
    /// 生成偏好描述
    func generatePreferenceDescription() -> String {
        var desc: [String] = []
        
        // 偏好的类型
        let preferred = typeWeights.filter { $0.value > 0.7 }.keys
        if !preferred.isEmpty {
            desc.append("用户更喜欢：\(preferred.map { $0.displayName }.joined(separator: "、"))类建议")
        }
        
        // 不喜欢的类型
        let disliked = typeWeights.filter { $0.value < 0.3 }.keys
        if !disliked.isEmpty {
            desc.append("用户不太接受：\(disliked.map { $0.displayName }.joined(separator: "、"))类建议")
        }
        
        // 常见拒绝原因
        if let topRejection = rejectionPatterns.max(by: { $0.value < $1.value }) {
            desc.append("避免：\(topRejection.key)")
        }
        
        return desc.joined(separator: "\n")
    }
    
    /// 获取统计
    func getStats() -> PreferenceStats {
        return PreferenceStats(
            typeWeights: typeWeights,
            topRejections: rejectionPatterns.sorted { $0.value > $1.value }.prefix(3).map { $0.key },
            acceptedPatternCount: acceptedPatterns.count
        )
    }
    
    // MARK: - 辅助方法
    
    private func extractKeywords(from text: String) -> Set<String> {
        // 简单分词（实际可用NLP库）
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return Set(words.filter { $0.count > 2 }) // 长度>2的词
    }
}

// MARK: - 数据结构

struct PreferenceStats {
    let typeWeights: [SmartSuggestion.SuggestionType: Double]
    let topRejections: [String]
    let acceptedPatternCount: Int
}

// SuggestionType 扩展
extension SmartSuggestion.SuggestionType {
    var displayName: String {
        switch self {
        case .efficiency: return "效率提升"
        case .habitImprovement: return "习惯养成"
        case .studyPlan: return "学习计划"
        case .goalSetting: return "目标设定"
        case .review: return "复习提醒"
        case .timeManagement: return "时间管理"
        case .warning: return "异常警告"
        }
    }
}

