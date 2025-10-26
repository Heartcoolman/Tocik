//
//  UserProfile.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v4.0 - 用户学习画像（持久化学习）
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var createdDate: Date
    var lastUpdatedDate: Date
    
    // 学习时间偏好（JSON格式）
    var timePreferencesData: String // {"bestHours": [9,10,14,15], "worstHours": [0,1,2,22,23]}
    
    // 习惯模式（JSON格式）
    var habitPatternsData: String // {"morningPerson": true, "weekendLearner": false}
    
    // 学习风格
    var learningStyle: LearningStyle
    var preferredSessionLength: Int // 偏好的番茄钟时长（分钟）
    var breakFrequency: Int // 多少个番茄钟后需要长休息
    
    // AI 建议反馈历史（用于强化学习）
    @Relationship(deleteRule: .cascade) var feedbackHistory: [SuggestionFeedback]
    
    // 统计数据（用于AI训练）
    var totalSuggestionsReceived: Int
    var totalSuggestionsAccepted: Int
    var totalSuggestionsRejected: Int
    var acceptanceRate: Double // 接受率
    
    // AI 分析历史摘要
    var lastAIAnalysisDate: Date?
    var aiInsightsData: String // JSON格式存储AI的长期洞察
    
    // Token统计（v5.0新增）
    var totalTokensUsed: Int // 总消耗token数
    var totalAIAnalysisCalls: Int // AI分析调用次数
    var totalAIRecommendationCalls: Int // AI推荐生成次数
    var lastMonthTokensUsed: Int // 本月消耗token数
    var monthResetDate: Date? // 月度重置日期
    
    // 推荐类型偏好权重（JSON格式）
    var recommendationPreferencesData: String
    
    enum LearningStyle: String, Codable {
        case visual = "视觉型"
        case auditory = "听觉型"
        case kinesthetic = "动手型"
        case reading = "阅读型"
        case mixed = "混合型"
    }
    
    init() {
        self.id = UUID()
        self.createdDate = Date()
        self.lastUpdatedDate = Date()
        self.timePreferencesData = "{}"
        self.habitPatternsData = "{}"
        self.learningStyle = .mixed
        self.preferredSessionLength = 25
        self.breakFrequency = 4
        self.feedbackHistory = []
        self.totalSuggestionsReceived = 0
        self.totalSuggestionsAccepted = 0
        self.totalSuggestionsRejected = 0
        self.acceptanceRate = 0
        self.lastAIAnalysisDate = nil
        self.aiInsightsData = "{}"
        
        // v5.0: Token统计初始化
        self.totalTokensUsed = 0
        self.totalAIAnalysisCalls = 0
        self.totalAIRecommendationCalls = 0
        self.lastMonthTokensUsed = 0
        self.monthResetDate = Date()
        
        // 初始化推荐偏好（默认权重都是 0.5 中性）
        self.recommendationPreferencesData = """
        {
            "habitTypeWeights": {},
            "goalCategoryWeights": {},
            "timePreferenceWeights": {},
            "difficultyWeights": {"easy": 0.5, "medium": 0.5, "hard": 0.5}
        }
        """
    }
    
    // 更新接受率
    func updateAcceptanceRate() {
        if totalSuggestionsReceived > 0 {
            acceptanceRate = Double(totalSuggestionsAccepted) / Double(totalSuggestionsReceived)
        }
    }
    
    // v5.0: 记录Token消耗
    func recordTokenUsage(tokens: Int, callType: AICallType) {
        totalTokensUsed += tokens
        lastMonthTokensUsed += tokens
        
        switch callType {
        case .analysis:
            totalAIAnalysisCalls += 1
        case .recommendation:
            totalAIRecommendationCalls += 1
        case .qa:
            break // 答疑不单独统计调用次数
        }
        
        // 检查是否需要重置月度统计
        checkMonthlyReset()
    }
    
    // 检查月度重置
    private func checkMonthlyReset() {
        guard let resetDate = monthResetDate else {
            monthResetDate = Date()
            return
        }
        
        let calendar = Calendar.current
        if !calendar.isDate(resetDate, equalTo: Date(), toGranularity: .month) {
            lastMonthTokensUsed = 0
            monthResetDate = Date()
        }
    }
    
    enum AICallType {
        case analysis      // 学习分析
        case recommendation // 推荐生成
        case qa            // 答疑助手
    }
}

// 推荐偏好结构（用于JSON解析）
struct RecommendationPreferences: Codable {
    var habitTypeWeights: [String: Double]      // 习惯类型权重
    var goalCategoryWeights: [String: Double]   // 目标类别权重
    var timePreferenceWeights: [String: Double] // 时间偏好权重
    var difficultyWeights: [String: Double]     // 难度偏好
}

// 建议反馈记录
@Model
final class SuggestionFeedback {
    var id: UUID
    var suggestionId: UUID
    var suggestionType: String
    var action: FeedbackAction
    var feedbackDate: Date
    var effectivenessRating: Int? // 1-5星评分（可选）
    var userComment: String?
    
    enum FeedbackAction: String, Codable {
        case accepted = "接受"
        case rejected = "拒绝"
        case deferred = "延后"
        case implemented = "已执行"
        case helpful = "有帮助"
        case notHelpful = "无帮助"
    }
    
    init(suggestionId: UUID, suggestionType: String, action: FeedbackAction) {
        self.id = UUID()
        self.suggestionId = suggestionId
        self.suggestionType = suggestionType
        self.action = action
        self.feedbackDate = Date()
    }
}

