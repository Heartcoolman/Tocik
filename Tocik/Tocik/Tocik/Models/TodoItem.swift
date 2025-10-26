//
//  TodoItem.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 增强版
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var category: String
    var createdDate: Date
    var completedDate: Date?
    var pomodoroCount: Int // 花费的番茄钟数量
    var estimatedPomodoros: Int // 预估需要的番茄钟数
    
    // v4.0 新增字段
    @Relationship(deleteRule: .cascade) var subTasks: [SubTask] // 子任务
    @Relationship(deleteRule: .cascade) var comments: [TaskComment] // 评论
    @Relationship(deleteRule: .cascade) var attachments: [Attachment] // 附件
    @Relationship(deleteRule: .nullify) var recurrenceRule: RecurrenceRule? // 重复规则
    var dependencyIds: String // 依赖的任务ID，逗号分隔
    var tagsData: String // 标签，逗号分隔
    var actualCompletionTime: Int // 实际完成时间（分钟）
    var smartRank: Double // 智能排序分数
    var lastModifiedDate: Date
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        case urgent = 3
        
        var displayName: String {
            switch self {
            case .low: return "低"
            case .medium: return "中"
            case .high: return "高"
            case .urgent: return "紧急"
            }
        }
        
        var colorHex: String {
            switch self {
            case .low: return "#95E1D3"
            case .medium: return "#FFD93D"
            case .high: return "#FF9A3D"
            case .urgent: return "#FF6B6B"
            }
        }
    }
    
    // 计算属性：标签数组
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    // 计算属性：依赖任务ID数组
    var dependencies: [UUID] {
        get {
            dependencyIds.isEmpty ? [] : dependencyIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            dependencyIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    init(title: String, notes: String = "", isCompleted: Bool = false, priority: Priority = .medium, dueDate: Date? = nil, category: String = "通用", estimatedPomodoros: Int = 1) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.category = category
        self.createdDate = Date()
        self.completedDate = nil
        self.pomodoroCount = 0
        self.estimatedPomodoros = estimatedPomodoros
        
        // v4.0 初始化
        self.subTasks = []
        self.comments = []
        self.attachments = []
        self.recurrenceRule = nil
        self.dependencyIds = ""
        self.tagsData = ""
        self.actualCompletionTime = 0
        self.smartRank = 0
        self.lastModifiedDate = Date()
    }
    
    // 子任务完成进度
    func subTasksProgress() -> Double {
        guard !subTasks.isEmpty else { return 1.0 }
        let completed = subTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subTasks.count)
    }
    
    // 是否可以开始（检查依赖）
    func canStart(allTodos: [TodoItem]) -> Bool {
        guard !dependencies.isEmpty else { return true }
        let dependentTodos = allTodos.filter { dependencies.contains($0.id) }
        return dependentTodos.allSatisfy { $0.isCompleted }
    }
    
    // 计算智能排序分数
    func calculateSmartRank() -> Double {
        var rank = 0.0
        
        // 优先级权重
        rank += Double(priority.rawValue) * 100
        
        // 截止日期权重
        if let dueDate = dueDate {
            let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
            if daysUntilDue < 0 {
                rank += 1000 // 已过期
            } else if daysUntilDue == 0 {
                rank += 500 // 今天到期
            } else {
                rank += max(0, 100 - Double(daysUntilDue) * 10)
            }
        }
        
        // 估算时长权重（短任务优先）
        rank += max(0, 50 - Double(estimatedPomodoros) * 5)
        
        self.smartRank = rank
        return rank
    }
}

