//
//  Exam.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  考试管理模型
//

import Foundation
import SwiftData

@Model
final class Exam {
    var id: UUID
    var examName: String
    var subject: String
    var examDate: Date
    var examType: ExamType
    var totalScore: Double?
    var actualScore: Double?
    var ranking: Int?
    var totalParticipants: Int?
    var prepStartDate: Date // 备考开始日期
    var isPassed: Bool
    var notes: String
    var createdDate: Date
    
    // 关联数据（使用ID存储，避免循环依赖）
    var relatedWrongQuestionIds: String // 逗号分隔的ID
    var reviewPlanId: UUID?
    
    enum ExamType: String, Codable, CaseIterable {
        case midterm = "期中考试"
        case final = "期末考试"
        case mock = "模拟考试"
        case formal = "正式考试"
        case quiz = "小测"
    }
    
    init(
        examName: String,
        subject: String,
        examDate: Date,
        examType: ExamType = .mock,
        prepStartDate: Date? = nil
    ) {
        self.id = UUID()
        self.examName = examName
        self.subject = subject
        self.examDate = examDate
        self.examType = examType
        self.totalScore = nil
        self.actualScore = nil
        self.ranking = nil
        self.totalParticipants = nil
        self.prepStartDate = prepStartDate ?? Calendar.current.date(byAdding: .day, value: -14, to: examDate)!
        self.isPassed = false
        self.notes = ""
        self.createdDate = Date()
        self.relatedWrongQuestionIds = ""
        self.reviewPlanId = nil
    }
    
    // 计算剩余天数
    func daysRemaining() -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
    
    // 是否已结束
    var isFinished: Bool {
        examDate < Date()
    }
    
    // 成绩百分比
    var scorePercentage: Double? {
        guard let actual = actualScore, let total = totalScore, total > 0 else { return nil }
        return (actual / total) * 100
    }
}

