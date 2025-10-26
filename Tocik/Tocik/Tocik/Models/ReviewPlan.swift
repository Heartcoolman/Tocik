//
//  ReviewPlan.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  复习计划模型（艾宾浩斯遗忘曲线）
//

import Foundation
import SwiftData

@Model
final class ReviewPlan {
    var id: UUID
    var planName: String
    var subject: String
    var startDate: Date
    var endDate: Date
    var reviewMethod: ReviewMethod
    var status: PlanStatus
    var createdDate: Date
    
    @Relationship(deleteRule: .cascade) var reviewSessions: [ReviewSession]
    
    enum ReviewMethod: String, Codable {
        case ebbinghaus = "艾宾浩斯曲线"
        case spaced = "间隔重复"
        case cyclic = "循环复习"
        case custom = "自定义"
    }
    
    enum PlanStatus: String, Codable {
        case active = "进行中"
        case completed = "已完成"
        case paused = "已暂停"
    }
    
    init(
        planName: String,
        subject: String,
        startDate: Date,
        endDate: Date,
        reviewMethod: ReviewMethod = .ebbinghaus
    ) {
        self.id = UUID()
        self.planName = planName
        self.subject = subject
        self.startDate = startDate
        self.endDate = endDate
        self.reviewMethod = reviewMethod
        self.status = .active
        self.createdDate = Date()
        self.reviewSessions = []
    }
    
    // 生成艾宾浩斯复习计划
    func generateEbbinghausSessions() {
        let intervals = [1, 2, 4, 7, 15, 30] // 艾宾浩斯间隔（天）
        for interval in intervals {
            if let sessionDate = Calendar.current.date(byAdding: .day, value: interval, to: startDate) {
                let session = ReviewSession(scheduledDate: sessionDate, reviewContent: planName)
                reviewSessions.append(session)
            }
        }
    }
    
    // 完成进度
    func progress() -> Double {
        guard !reviewSessions.isEmpty else { return 0 }
        let completed = reviewSessions.filter { $0.isCompleted }.count
        return Double(completed) / Double(reviewSessions.count)
    }
}

@Model
final class ReviewSession {
    var id: UUID
    var scheduledDate: Date
    var actualDate: Date?
    var isCompleted: Bool
    var reviewContent: String
    var effectivenessRating: Int? // 1-5星
    var notes: String
    
    init(scheduledDate: Date, reviewContent: String) {
        self.id = UUID()
        self.scheduledDate = scheduledDate
        self.actualDate = nil
        self.isCompleted = false
        self.reviewContent = reviewContent
        self.effectivenessRating = nil
        self.notes = ""
    }
}

