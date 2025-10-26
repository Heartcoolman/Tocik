//
//  WrongQuestion.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class WrongQuestion {
    var id: UUID
    var subject: String // 科目名称（用于显示）
    var subjectId: UUID? // v5.0: 关联科目ID
    @Attribute(.externalStorage) var questionImageData: Data? // 题目照片
    var analysis: String // 解析
    var note: String // 笔记
    var tagsData: String // 标签（逗号分隔）
    var masteryLevel: MasteryLevel
    var reviewCount: Int
    var lastReviewDate: Date?
    var createdDate: Date
    var nextReviewDate: Date
    
    // v4.0 新增字段
    var knowledgePoints: String // 知识点标签，逗号分隔
    var errorType: ErrorType // 错误类型
    var relatedQuestionIds: String // 关联错题ID，逗号分隔
    var masteryScore: Double // 掌握度评分 (0-100)
    var difficultyRating: Int // 难度评分 (1-5)
    var sourceInfo: String // 来源信息（如：期中考试、练习册P123）
    
    enum ErrorType: String, Codable, CaseIterable {
        case careless = "粗心大意"
        case notUnderstand = "概念不清"
        case notMaster = "未掌握"
        case calculation = "计算错误"
        case misread = "审题不清"
        case other = "其他"
        
        var colorHex: String {
            switch self {
            case .careless: return "#FFD93D"
            case .notUnderstand: return "#FF6B6B"
            case .notMaster: return "#FF9A3D"
            case .calculation: return "#A78BFA"
            case .misread: return "#4ECDC4"
            case .other: return "#95E1D3"
            }
        }
    }
    
    // 计算属性
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    enum MasteryLevel: Int, Codable, CaseIterable {
        case notMastered = 0
        case reviewing = 1
        case mastered = 2
        
        var displayName: String {
            switch self {
            case .notMastered: return "未掌握"
            case .reviewing: return "复习中"
            case .mastered: return "已掌握"
            }
        }
        
        var colorHex: String {
            switch self {
            case .notMastered: return "#FF6B6B"
            case .reviewing: return "#FFD93D"
            case .mastered: return "#4ECDC4"
            }
        }
    }
    
    var relatedQuestions: [UUID] {
        get {
            relatedQuestionIds.isEmpty ? [] : relatedQuestionIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            relatedQuestionIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    init(subject: String, questionImageData: Data? = nil, analysis: String = "", note: String = "", errorType: ErrorType = .notUnderstand, subjectId: UUID? = nil) {
        self.id = UUID()
        self.subject = subject
        self.subjectId = subjectId // v5.0
        self.questionImageData = questionImageData
        self.analysis = analysis
        self.note = note
        self.tagsData = ""
        self.masteryLevel = .notMastered
        self.reviewCount = 0
        self.lastReviewDate = nil
        self.createdDate = Date()
        self.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        // v4.0 初始化
        self.knowledgePoints = ""
        self.errorType = errorType
        self.relatedQuestionIds = ""
        self.masteryScore = 0
        self.difficultyRating = 3
        self.sourceInfo = ""
    }
    
    // 更新掌握度评分
    func updateMasteryScore() {
        // 基于复习次数和掌握程度计算分数
        var score = 0.0
        
        switch masteryLevel {
        case .notMastered:
            score = Double(reviewCount) * 10
        case .reviewing:
            score = 40 + Double(reviewCount) * 10
        case .mastered:
            score = 80 + Double(reviewCount) * 5
        }
        
        self.masteryScore = min(score, 100)
    }
}

