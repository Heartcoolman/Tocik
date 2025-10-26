//
//  LearningPath.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 学习路径规划
//

import Foundation
import SwiftData

@Model
final class LearningPath {
    var id: UUID
    var name: String
    var pathDescription: String
    var subject: String
    var targetDate: Date
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var milestones: [LearningMilestone]
    var colorHex: String
    var isCompleted: Bool
    
    init(name: String, pathDescription: String = "", subject: String, targetDate: Date, colorHex: String = "#8B5CF6") {
        self.id = UUID()
        self.name = name
        self.pathDescription = pathDescription
        self.subject = subject
        self.targetDate = targetDate
        self.createdDate = Date()
        self.milestones = []
        self.colorHex = colorHex
        self.isCompleted = false
    }
    
    // 总体进度
    func overallProgress() -> Double {
        guard !milestones.isEmpty else { return 0 }
        let completedCount = milestones.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(milestones.count)
    }
}

@Model
final class LearningMilestone {
    var id: UUID
    var title: String
    var milestoneDescription: String
    var orderIndex: Int
    var estimatedHours: Int
    var actualHours: Int
    var isCompleted: Bool
    var completedDate: Date?
    var relatedFlashDeckIds: String // 关联的闪卡组ID，逗号分隔
    var relatedNoteIds: String // 关联的笔记ID，逗号分隔
    
    init(title: String, milestoneDescription: String = "", orderIndex: Int, estimatedHours: Int = 0) {
        self.id = UUID()
        self.title = title
        self.milestoneDescription = milestoneDescription
        self.orderIndex = orderIndex
        self.estimatedHours = estimatedHours
        self.actualHours = 0
        self.isCompleted = false
        self.completedDate = nil
        self.relatedFlashDeckIds = ""
        self.relatedNoteIds = ""
    }
    
    var relatedFlashDecks: [UUID] {
        get {
            relatedFlashDeckIds.isEmpty ? [] : relatedFlashDeckIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            relatedFlashDeckIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    var relatedNotes: [UUID] {
        get {
            relatedNoteIds.isEmpty ? [] : relatedNoteIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            relatedNoteIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
}

