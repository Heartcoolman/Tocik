//
//  FlashCard.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class FlashCard {
    var id: UUID
    var question: String
    var answer: String
    var difficulty: Difficulty
    var nextReviewDate: Date
    var reviewCount: Int
    var correctCount: Int
    var easeFactor: Double // SM-2算法的难易度
    var interval: Int // 复习间隔（天）
    var createdDate: Date
    var lastReviewDate: Date?
    var subjectId: UUID? // v5.0: 关联科目ID
    
    // v4.0 新增字段
    var cardType: CardType // 卡片类型
    var tagsData: String // 标签，逗号分隔
    var enableVoiceReading: Bool // 语音朗读
    var learningCurveData: String // 学习曲线数据（JSON格式）
    var hint: String // 提示
    var explanation: String // 详细解释
    var options: String // 选择题选项（JSON格式）
    
    enum CardType: String, Codable {
        case basic = "问答"
        case fillBlank = "填空"
        case multipleChoice = "选择"
        case matching = "匹配"
        
        var icon: String {
            switch self {
            case .basic: return "text.bubble"
            case .fillBlank: return "text.insert"
            case .multipleChoice: return "list.bullet.circle"
            case .matching: return "arrow.left.arrow.right"
            }
        }
    }
    
    enum Difficulty: Int, Codable, CaseIterable {
        case easy = 0
        case medium = 1
        case hard = 2
        
        var displayName: String {
            switch self {
            case .easy: return "简单"
            case .medium: return "中等"
            case .hard: return "困难"
            }
        }
        
        var colorHex: String {
            switch self {
            case .easy: return "#4ECDC4"
            case .medium: return "#FFD93D"
            case .hard: return "#FF6B6B"
            }
        }
    }
    
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    init(question: String, answer: String, difficulty: Difficulty = .medium, cardType: CardType = .basic, subjectId: UUID? = nil) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.difficulty = difficulty
        self.nextReviewDate = Date()
        self.reviewCount = 0
        self.correctCount = 0
        self.easeFactor = 2.5
        self.interval = 0
        self.createdDate = Date()
        self.lastReviewDate = nil
        self.subjectId = subjectId // v5.0
        
        // v4.0 初始化
        self.cardType = cardType
        self.tagsData = ""
        self.enableVoiceReading = false
        self.learningCurveData = "[]"
        self.hint = ""
        self.explanation = ""
        self.options = "[]"
    }
    
    // 正确率
    var accuracyRate: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount)
    }
}

@Model
final class FlashDeck {
    var id: UUID
    var name: String
    var deckDescription: String
    @Relationship(deleteRule: .cascade) var cards: [FlashCard]
    var colorHex: String
    var relatedCourseId: UUID? // 关联课程
    var createdDate: Date
    
    init(name: String, deckDescription: String = "", colorHex: String = "#4A90E2", relatedCourseId: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.deckDescription = deckDescription
        self.cards = []
        self.colorHex = colorHex
        self.relatedCourseId = relatedCourseId
        self.createdDate = Date()
    }
    
    // 需要复习的卡片数量
    func cardsNeedReview() -> Int {
        cards.filter { $0.nextReviewDate <= Date() }.count
    }
}

