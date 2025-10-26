//
//  RecommendedAction.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v4.0 - AI推荐行动模型（学习计划、习惯推荐）
//

import Foundation
import SwiftData

@Model
final class RecommendedAction {
    var id: UUID
    var recommendationType: RecommendationType
    var title: String
    var actionDescription: String
    var reason: String // AI推荐理由
    var configurationData: String // JSON格式存储详细配置
    var priority: Int // 1-10优先级
    var createdDate: Date
    var status: ActionStatus
    var aiConfidence: Double // AI置信度 0-1
    
    enum RecommendationType: String, Codable {
        case habit = "习惯"
        case goal = "目标"
        case studyPlan = "学习计划"
    }
    
    enum ActionStatus: String, Codable {
        case pending = "待选择"
        case accepted = "已接受"
        case rejected = "已拒绝"
    }
    
    init(
        recommendationType: RecommendationType,
        title: String,
        actionDescription: String,
        reason: String,
        configurationData: String = "{}",
        priority: Int = 5,
        aiConfidence: Double = 0.7
    ) {
        self.id = UUID()
        self.recommendationType = recommendationType
        self.title = title
        self.actionDescription = actionDescription
        self.reason = reason
        self.configurationData = configurationData
        self.priority = priority
        self.createdDate = Date()
        self.status = .pending
        self.aiConfidence = aiConfidence
    }
}

