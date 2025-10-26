//
//  QASession.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  答疑助手记录模型
//

import Foundation
import SwiftData

@Model
final class QASession {
    var id: UUID
    var question: String
    @Attribute(.externalStorage) var questionImageData: Data? // OCR识别的题目图片
    var aiAnswer: String
    var subject: String
    var difficulty: Difficulty
    var createdDate: Date
    var isSaved: Bool // 是否保存到错题本
    var relatedWrongQuestionId: UUID?
    var isFavorite: Bool
    
    enum Difficulty: String, Codable {
        case easy = "简单"
        case medium = "中等"
        case hard = "困难"
    }
    
    init(
        question: String,
        subject: String = "未分类",
        difficulty: Difficulty = .medium,
        questionImageData: Data? = nil
    ) {
        self.id = UUID()
        self.question = question
        self.questionImageData = questionImageData
        self.aiAnswer = ""
        self.subject = subject
        self.difficulty = difficulty
        self.createdDate = Date()
        self.isSaved = false
        self.relatedWrongQuestionId = nil
        self.isFavorite = false
    }
}

