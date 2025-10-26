//
//  Goal.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var goalDescription: String
    var timeframe: Timeframe
    var startDate: Date
    var endDate: Date
    @Relationship(deleteRule: .cascade) var keyResults: [KeyResult]
    var colorHex: String
    var isArchived: Bool
    
    // v4.0 新增字段
    var relatedTodoIds: String // 自动拆解的待办任务ID，逗号分隔
    var completionPrediction: Date? // 预计完成日期
    var lastUpdateDate: Date // 最后更新日期
    var motivationNote: String // 动机说明
    
    enum Timeframe: String, Codable {
        case yearly = "年度"
        case quarterly = "季度"
        case monthly = "月度"
    }
    
    var relatedTodos: [UUID] {
        get {
            relatedTodoIds.isEmpty ? [] : relatedTodoIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            relatedTodoIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    init(title: String, goalDescription: String = "", timeframe: Timeframe, startDate: Date, endDate: Date, colorHex: String = "#A78BFA") {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.timeframe = timeframe
        self.startDate = startDate
        self.endDate = endDate
        self.keyResults = []
        self.colorHex = colorHex
        self.isArchived = false
        
        // v4.0 初始化
        self.relatedTodoIds = ""
        self.completionPrediction = nil
        self.lastUpdateDate = Date()
        self.motivationNote = ""
    }
    
    // 计算整体进度
    func overallProgress() -> Double {
        guard !keyResults.isEmpty else { return 0 }
        let total = keyResults.reduce(0.0) { $0 + $1.progress }
        return total / Double(keyResults.count)
    }
    
    // 预测完成日期
    func predictCompletionDate() -> Date? {
        let progress = overallProgress()
        guard progress > 0 && progress < 100 else { return nil }
        
        let elapsed = Date().timeIntervalSince(startDate)
        let estimatedTotal = elapsed / (progress / 100.0)
        let remaining = estimatedTotal - elapsed
        
        return Date().addingTimeInterval(remaining)
    }
    
    // 更新预测
    func updatePrediction() {
        self.completionPrediction = predictCompletionDate()
        self.lastUpdateDate = Date()
    }
}

@Model
final class KeyResult {
    var id: UUID
    var title: String
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var progress: Double // 0-100
    
    init(title: String, targetValue: Double, currentValue: Double = 0, unit: String = "") {
        self.id = UUID()
        self.title = title
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.progress = min(currentValue / targetValue * 100, 100)
    }
    
    func updateProgress() {
        self.progress = min(currentValue / targetValue * 100, 100)
    }
}

