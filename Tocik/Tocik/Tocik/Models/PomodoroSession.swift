//
//  PomodoroSession.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 增强版
//

import Foundation
import SwiftData

@Model
final class PomodoroSession {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var sessionType: SessionType
    var isCompleted: Bool
    
    // v4.0 新增字段
    var interruptionCount: Int // 中断次数
    var focusScore: Double // 专注度评分 (0-100)
    var sessionMode: SessionMode // 时长模式
    var teamSessionId: UUID? // 团队番茄钟ID（可选）
    var relatedTodoId: UUID? // 关联的待办任务
    var subjectId: UUID? // v5.0: 关联的科目ID
    var note: String // 备注
    
    enum SessionType: String, Codable {
        case work = "工作"
        case shortBreak = "短休息"
        case longBreak = "长休息"
    }
    
    enum SessionMode: String, Codable {
        case standard = "标准 (25分钟)"
        case long = "深度 (50分钟)"
        case short = "快速 (15分钟)"
        case custom = "自定义"
        
        var duration: Int {
            switch self {
            case .standard: return 25
            case .long: return 50
            case .short: return 15
            case .custom: return 25
            }
        }
    }
    
    init(startTime: Date = Date(), endTime: Date = Date(), sessionType: SessionType = .work, isCompleted: Bool = false, sessionMode: SessionMode = .standard, subjectId: UUID? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.sessionType = sessionType
        self.isCompleted = isCompleted
        
        // v4.0 初始化
        self.interruptionCount = 0
        self.focusScore = 100.0
        self.sessionMode = sessionMode
        self.teamSessionId = nil
        self.relatedTodoId = nil
        self.subjectId = subjectId // v5.0
        self.note = ""
    }
    
    // 计算专注度评分
    func calculateFocusScore() -> Double {
        let baseScore = 100.0
        let interruptionPenalty = Double(interruptionCount) * 10.0
        let score = max(0, baseScore - interruptionPenalty)
        self.focusScore = score
        return score
    }
    
    // 实际时长（分钟）
    var actualDuration: Int {
        let seconds = endTime.timeIntervalSince(startTime)
        return Int(seconds / 60)
    }
}

