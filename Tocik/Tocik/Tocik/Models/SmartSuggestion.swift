//
//  SmartSuggestion.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 智能建议系统
//

import Foundation
import SwiftData

@Model
final class SmartSuggestion {
    var id: UUID
    var suggestionType: SuggestionType
    var title: String
    var content: String
    var priority: Priority
    var createdDate: Date
    var expiryDate: Date?
    var isRead: Bool
    var isActioned: Bool
    var relatedItemId: UUID? // 关联的项目ID
    var actionType: ActionType?
    
    // v4.1 新增：反馈和AI标记
    var isAIGenerated: Bool // 标记是否由AI生成
    var aiConfidence: Double? // AI生成的置信度 (0-1)
    var userFeedback: String? // 用户反馈类型（helpful/notHelpful等）
    var feedbackDate: Date? // 反馈时间
    
    enum SuggestionType: String, Codable {
        case timeManagement = "时间管理"
        case studyPlan = "学习计划"
        case habitImprovement = "习惯改善"
        case goalSetting = "目标设定"
        case review = "复习提醒"
        case efficiency = "效率提升"
        case warning = "异常警告"
    }
    
    enum Priority: Int, Codable {
        case low = 0
        case medium = 1
        case high = 2
    }
    
    enum ActionType: String, Codable {
        case createTodo = "创建待办"
        case adjustSchedule = "调整计划"
        case reviewFlashcards = "复习闪卡"
        case reviewWrongQuestions = "复习错题"
        case setGoal = "设定目标"
        case other = "其他"
    }
    
    init(suggestionType: SuggestionType, title: String, content: String, priority: Priority = .medium, relatedItemId: UUID? = nil, actionType: ActionType? = nil, isAIGenerated: Bool = false, aiConfidence: Double? = nil) {
        self.id = UUID()
        self.suggestionType = suggestionType
        self.title = title
        self.content = content
        self.priority = priority
        self.createdDate = Date()
        self.expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        self.isRead = false
        self.isActioned = false
        self.relatedItemId = relatedItemId
        self.actionType = actionType
        self.isAIGenerated = isAIGenerated
        self.aiConfidence = aiConfidence
        self.userFeedback = nil
        self.feedbackDate = nil
    }
    
    var priorityColor: String {
        switch priority {
        case .low: return "#95E1D3"
        case .medium: return "#FFD93D"
        case .high: return "#FF6B6B"
        }
    }
}

