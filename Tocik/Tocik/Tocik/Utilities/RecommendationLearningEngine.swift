//
//  RecommendationLearningEngine.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v4.1 - 推荐学习引擎（反馈自动学习）
//

import Foundation
import SwiftData

@MainActor
class RecommendationLearningEngine {
    
    // MARK: - 记录反馈并更新权重
    
    /// 记录用户反馈并自动学习
    static func recordFeedback(
        recommendation: RecommendedAction,
        feedback: SuggestionFeedback.FeedbackAction,
        userProfile: UserProfile?,
        context: ModelContext
    ) {
        guard let userProfile = userProfile else { return }
        
        // 1. 创建反馈记录
        let feedbackRecord = SuggestionFeedback(
            suggestionId: recommendation.id,
            suggestionType: recommendation.recommendationType.rawValue,
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
            recommendation: recommendation,
            feedback: feedback,
            userProfile: userProfile
        )
        
        print("📊 反馈已记录: \(feedback.rawValue) - 接受率: \(String(format: "%.1f%%", userProfile.acceptanceRate * 100))")
    }
    
    // MARK: - 更新偏好权重算法
    
    private static func updatePreferenceWeights(
        recommendation: RecommendedAction,
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
        
        // 1. 更新类型权重
        let type = recommendation.recommendationType.rawValue
        let currentWeight = preferences.habitTypeWeights[type] ?? 0.5
        let newWeight = clamp(currentWeight + weightAdjustment, min: 0.0, max: 1.0)
        preferences.habitTypeWeights[type] = newWeight
        
        print("🎯 权重更新: \(type) \(currentWeight) → \(newWeight)")
        
        // 2. 尝试从配置中提取更多维度并更新权重
        if let configData = recommendation.configurationData.data(using: .utf8),
           let config = try? JSONSerialization.jsonObject(with: configData) as? [String: Any] {
            
            // 更新时间偏好权重
            if let timeSlot = config["timeSlot"] as? String {
                let currentTimeWeight = preferences.timePreferenceWeights[timeSlot] ?? 0.5
                preferences.timePreferenceWeights[timeSlot] = clamp(currentTimeWeight + weightAdjustment, min: 0.0, max: 1.0)
            }
            
            // 更新难度权重
            if let difficulty = config["difficulty"] as? String {
                let currentDiffWeight = preferences.difficultyWeights[difficulty] ?? 0.5
                preferences.difficultyWeights[difficulty] = clamp(currentDiffWeight + weightAdjustment, min: 0.0, max: 1.0)
            }
            
            // 更新分类权重
            if let category = config["category"] as? String {
                let currentCategoryWeight = preferences.goalCategoryWeights[category] ?? 0.5
                preferences.goalCategoryWeights[category] = clamp(currentCategoryWeight + weightAdjustment, min: 0.0, max: 1.0)
            }
        }
        
        // 保存更新后的权重
        if let updatedData = try? JSONEncoder().encode(preferences),
           let jsonString = String(data: updatedData, encoding: .utf8) {
            userProfile.recommendationPreferencesData = jsonString
            userProfile.lastUpdatedDate = Date()
        }
    }
    
    // MARK: - 基于权重过滤推荐
    
    /// 根据用户历史反馈过滤和排序推荐
    static func filterAndRankRecommendations(
        recommendations: [RecommendedAction],
        userProfile: UserProfile
    ) -> [RecommendedAction] {
        // 解析用户偏好
        guard let preferencesData = userProfile.recommendationPreferencesData.data(using: .utf8),
              let preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) else {
            return recommendations
        }
        
        // 为每个推荐计算得分
        var scoredRecommendations: [(RecommendedAction, Double)] = []
        
        for recommendation in recommendations {
            var score = Double(recommendation.priority) / 10.0 // 基础分 0-1
            
            // 1. 类型权重影响 (权重 0.4)
            let typeWeight = preferences.habitTypeWeights[recommendation.recommendationType.rawValue] ?? 0.5
            score = score * 0.6 + typeWeight * 0.4
            
            // 解析配置获取更多维度
            if let configData = recommendation.configurationData.data(using: .utf8),
               let config = try? JSONSerialization.jsonObject(with: configData) as? [String: Any] {
                
                // 2. 时间偏好影响 (权重 0.2)
                if let timeSlot = config["timeSlot"] as? String {
                    let timeWeight = preferences.timePreferenceWeights[timeSlot] ?? 0.5
                    score = score * 0.8 + timeWeight * 0.2
                }
                
                // 3. 难度偏好影响 (权重 0.2)
                if let difficulty = config["difficulty"] as? String {
                    let diffWeight = preferences.difficultyWeights[difficulty] ?? 0.5
                    score = score * 0.8 + diffWeight * 0.2
                }
                
                // 4. 分类权重影响 (权重 0.2)
                if let category = config["category"] as? String {
                    let categoryWeight = preferences.goalCategoryWeights[category] ?? 0.5
                    score = score * 0.8 + categoryWeight * 0.2
                }
            }
            
            scoredRecommendations.append((recommendation, score))
        }
        
        // 按得分排序并过滤低分推荐
        let filtered = scoredRecommendations
            .filter { $0.1 >= 0.3 }  // 过滤得分低于 0.3 的推荐
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
        
        print("🔍 推荐过滤: \(recommendations.count) → \(filtered.count) 条")
        return filtered
    }
    
    // MARK: - 辅助方法
    
    private static func clamp(_ value: Double, min minValue: Double, max maxValue: Double) -> Double {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}

