//
//  PreferenceLearningEngine.swift
//  Tocik
//
//  Created: 2025/10/24
//  重构: 偏好学习引擎（整合 RecommendationLearningEngine 和 FeedbackLearningLoop）
//

import Foundation
import SwiftData

/// 偏好学习引擎 - 基于用户反馈持续学习和优化建议
@MainActor
class PreferenceLearningEngine {
    
    // MARK: - 反馈记录
    
    /// 记录用户反馈并自动学习
    static func recordFeedback(
        suggestionId: UUID,
        suggestionType: String,
        feedback: SuggestionFeedback.FeedbackAction,
        userProfile: UserProfile,
        context: ModelContext
    ) {
        // 1. 创建反馈记录
        let feedbackRecord = SuggestionFeedback(
            suggestionId: suggestionId,
            suggestionType: suggestionType,
            action: feedback
        )
        userProfile.feedbackHistory.append(feedbackRecord)
        context.insert(feedbackRecord)
        
        // 2. 更新用户画像统计
        userProfile.totalSuggestionsReceived += 1
        if feedback == .accepted || feedback == .implemented || feedback == .helpful {
            userProfile.totalSuggestionsAccepted += 1
        } else if feedback == .rejected || feedback == .notHelpful {
            userProfile.totalSuggestionsRejected += 1
        }
        userProfile.updateAcceptanceRate()
        
        // 3. 更新偏好权重（关键！）
        updatePreferenceWeights(
            suggestionType: suggestionType,
            feedback: feedback,
            userProfile: userProfile
        )
        
        print("📊 反馈已记录: \(feedback.rawValue) - 接受率: \(String(format: "%.1f%%", userProfile.acceptanceRate * 100))")
    }
    
    // MARK: - 偏好权重管理
    
    private static func updatePreferenceWeights(
        suggestionType: String,
        feedback: SuggestionFeedback.FeedbackAction,
        userProfile: UserProfile
    ) {
        // 解析当前权重
        guard let preferencesData = userProfile.recommendationPreferencesData.data(using: .utf8),
              var preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) else {
            print("⚠️ 无法解析偏好权重")
            return
        }
        
        // 学习率（调整幅度）
        let learningRate = 0.1
        
        // 根据反馈调整权重
        let weightAdjustment: Double
        switch feedback {
        case .accepted, .implemented, .helpful:
            weightAdjustment = +learningRate  // 增加权重
        case .rejected, .notHelpful:
            weightAdjustment = -learningRate  // 降低权重
        case .deferred:
            weightAdjustment = -0.02  // 轻微降低
        }
        
        // 更新类型权重
        let currentWeight = preferences.habitTypeWeights[suggestionType] ?? 0.5
        let newWeight = clamp(currentWeight + weightAdjustment, min: 0.0, max: 1.0)
        preferences.habitTypeWeights[suggestionType] = newWeight
        
        print("🎯 权重更新: \(suggestionType) \(currentWeight) → \(newWeight)")
        
        // 保存更新后的权重
        if let updatedData = try? JSONEncoder().encode(preferences),
           let jsonString = String(data: updatedData, encoding: .utf8) {
            userProfile.recommendationPreferencesData = jsonString
            userProfile.lastUpdatedDate = Date()
        }
    }
    
    // MARK: - 基于偏好过滤建议
    
    /// 根据用户历史反馈过滤和优化建议
    static func filterByPreferences(
        suggestions: [SmartSuggestion],
        userProfile: UserProfile
    ) -> [SmartSuggestion] {
        // 解析用户偏好
        guard let preferencesData = userProfile.recommendationPreferencesData.data(using: .utf8),
              let preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) else {
            return suggestions
        }
        
        // 过滤权重过低的建议类型
        let filteredSuggestions = suggestions.filter { suggestion in
            let weight = preferences.habitTypeWeights[suggestion.suggestionType.rawValue] ?? 0.5
            return weight >= 0.3  // 权重低于0.3的类型不再推荐
        }
        
        return filteredSuggestions
    }
    
    // MARK: - AI Prompt 增强
    
    /// 增强AI Prompt，融入学习到的偏好
    static func enhanceAIPrompt(_ basePrompt: String, userProfile: UserProfile) -> String {
        // 解析偏好
        guard let preferencesData = userProfile.recommendationPreferencesData.data(using: .utf8),
              let preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) else {
            return basePrompt
        }
        
        // 生成偏好描述
        let preferenceDescription = generatePreferenceDescription(preferences)
        
        guard !preferenceDescription.isEmpty else {
            return basePrompt
        }
        
        let enhancedPrompt = """
        \(basePrompt)
        
        ## 🎯 用户偏好（基于历史反馈学习）
        \(preferenceDescription)
        
        请优先生成符合用户偏好的建议。
        """
        
        return enhancedPrompt
    }
    
    private static func generatePreferenceDescription(_ preferences: RecommendationPreferences) -> String {
        var lines: [String] = []
        
        // 分析类型偏好
        let sortedTypes = preferences.habitTypeWeights.sorted { $0.value > $1.value }
        if let mostLiked = sortedTypes.first, mostLiked.value > 0.6 {
            lines.append("- 用户喜欢「\(mostLiked.key)」类型的建议")
        }
        if let leastLiked = sortedTypes.last, leastLiked.value < 0.4 {
            lines.append("- 用户不太喜欢「\(leastLiked.key)」类型的建议")
        }
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - 辅助函数
    
    private static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.min(Swift.max(value, min), max)
    }
}

// MARK: - 数据模型

struct PreferenceModel {
    var typeWeights: [String: Double] = [:]
    var rejectionPatterns: [String] = []
    
    mutating func update(suggestionType: SmartSuggestion.SuggestionType, action: SuggestionFeedback.FeedbackAction) {
        let key = suggestionType.rawValue
        let currentWeight = typeWeights[key] ?? 0.5
        
        switch action {
        case .accepted, .implemented, .helpful:
            typeWeights[key] = min(currentWeight + 0.1, 1.0)
        case .rejected, .notHelpful:
            typeWeights[key] = max(currentWeight - 0.1, 0.0)
        case .deferred:
            typeWeights[key] = max(currentWeight - 0.02, 0.0)
        }
    }
    
    mutating func learnRejectionPattern(reason: String) {
        if !rejectionPatterns.contains(reason) {
            rejectionPatterns.append(reason)
        }
    }
    
    mutating func boostType(_ type: SmartSuggestion.SuggestionType) {
        let key = type.rawValue
        let currentWeight = typeWeights[key] ?? 0.5
        typeWeights[key] = min(currentWeight + 0.15, 1.0)
    }
}

