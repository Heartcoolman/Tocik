//
//  StudyJournal.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  学习日志模型
//

import Foundation
import SwiftData

@Model
final class StudyJournal {
    var id: UUID
    var date: Date
    var content: String
    var mood: Mood
    var studyHours: Double
    var highlights: String // 今日亮点
    var challenges: String // 遇到的困难
    var reflections: String // 反思总结
    var tomorrowPlan: String // 明日计划
    var pomodoroCount: Int // 今日番茄钟数
    var tasksCompleted: Int // 今日完成任务数
    
    enum Mood: Int, Codable, CaseIterable {
        case terrible = 1
        case bad = 2
        case okay = 3
        case good = 4
        case excellent = 5
        
        var emoji: String {
            switch self {
            case .terrible: return "😢"
            case .bad: return "😔"
            case .okay: return "😐"
            case .good: return "😊"
            case .excellent: return "😄"
            }
        }
        
        var displayName: String {
            switch self {
            case .terrible: return "很糟"
            case .bad: return "不好"
            case .okay: return "一般"
            case .good: return "不错"
            case .excellent: return "很棒"
            }
        }
    }
    
    init(date: Date = Date(), mood: Mood = .okay) {
        self.id = UUID()
        self.date = date
        self.content = ""
        self.mood = mood
        self.studyHours = 0
        self.highlights = ""
        self.challenges = ""
        self.reflections = ""
        self.tomorrowPlan = ""
        self.pomodoroCount = 0
        self.tasksCompleted = 0
    }
}

