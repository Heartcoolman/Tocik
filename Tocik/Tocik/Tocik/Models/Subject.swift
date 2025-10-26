//
//  Subject.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  科目管理模型
//

import Foundation
import SwiftData

@Model
final class Subject {
    var id: UUID
    var name: String
    var colorHex: String
    var icon: String
    var difficulty: Difficulty
    var teacher: String?
    var creditHours: Int?
    var targetScore: Double?
    var averageScore: Double?
    var createdDate: Date
    
    // 统计数据
    var totalStudyHours: Double
    var totalPomodoroSessions: Int
    var totalNotes: Int
    var totalFlashCards: Int
    var totalWrongQuestions: Int
    var totalExams: Int
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "简单"
        case medium = "中等"
        case hard = "困难"
    }
    
    init(
        name: String,
        colorHex: String? = nil,
        icon: String = "book.fill",
        difficulty: Difficulty = .medium,
        teacher: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex ?? Theme.subjectColors[name] ?? "#667EEA"
        self.icon = icon
        self.difficulty = difficulty
        self.teacher = teacher
        self.creditHours = nil
        self.targetScore = nil
        self.averageScore = nil
        self.createdDate = Date()
        self.totalStudyHours = 0
        self.totalPomodoroSessions = 0
        self.totalNotes = 0
        self.totalFlashCards = 0
        self.totalWrongQuestions = 0
        self.totalExams = 0
    }
    
    // 更新统计数据
    func updateStats(
        studyHours: Double = 0,
        pomodoros: Int = 0,
        notes: Int = 0,
        flashCards: Int = 0,
        wrongQuestions: Int = 0,
        exams: Int = 0
    ) {
        totalStudyHours += studyHours
        totalPomodoroSessions += pomodoros
        totalNotes += notes
        totalFlashCards += flashCards
        totalWrongQuestions += wrongQuestions
        totalExams += exams
    }
}

