//
//  Habit.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 增强版
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String // SF Symbol名称
    var colorHex: String
    var frequency: Frequency
    var targetCount: Int // 目标次数（每天/每周）
    var createdDate: Date
    @Relationship(deleteRule: .cascade) var records: [HabitRecord]
    
    // v4.0 新增字段
    var reminderTime: Date? // 提醒时间
    var reminderEnabled: Bool
    var habitScore: Double // 习惯评分 (0-100)
    var formationTarget: Int // 习惯形成目标天数 (21 或 66)
    var motivationNote: String // 动机笔记
    
    enum Frequency: String, Codable {
        case daily = "每天"
        case weekly = "每周"
    }
    
    init(name: String, icon: String = "star.fill", colorHex: String = "#4A90E2", frequency: Frequency = .daily, targetCount: Int = 1, formationTarget: Int = 21) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.targetCount = targetCount
        self.createdDate = Date()
        self.records = []
        
        // v4.0 初始化
        self.reminderTime = nil
        self.reminderEnabled = false
        self.habitScore = 0
        self.formationTarget = formationTarget
        self.motivationNote = ""
    }
    
    // 习惯形成进度（0-1）
    func formationProgress() -> Double {
        let streak = getCurrentStreak()
        return min(Double(streak) / Double(formationTarget), 1.0)
    }
    
    // 计算习惯评分
    func calculateHabitScore() -> Double {
        let streak = getCurrentStreak()
        let totalRecords = records.count
        
        // 连续性得分 (40分)
        let streakScore = min(Double(streak) / 30.0, 1.0) * 40
        
        // 总完成次数得分 (30分)
        let totalScore = min(Double(totalRecords) / 100.0, 1.0) * 30
        
        // 近期完成率得分 (30分)
        let recentDays = 7
        let recentRecords = records.filter {
            Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 999 <= recentDays
        }
        let recentRate = Double(recentRecords.count) / Double(recentDays)
        let recentScore = min(recentRate, 1.0) * 30
        
        let score = streakScore + totalScore + recentScore
        self.habitScore = score
        return score
    }
    
    // 获取连续打卡天数
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let sortedRecords = records.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Date()
        
        for record in sortedRecords {
            if calendar.isDate(record.date, inSameDayAs: currentDate) || 
               calendar.isDate(record.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                currentDate = record.date
            } else {
                break
            }
        }
        return streak
    }
}

@Model
final class HabitRecord {
    var id: UUID
    var date: Date
    var count: Int
    var note: String
    
    // v4.0 新增字段
    var mood: Mood? // 情绪评分
    @Attribute(.externalStorage) var photoData: Data? // 打卡照片
    var timeSpent: Int // 花费时间（分钟）
    
    enum Mood: Int, Codable {
        case veryBad = 1
        case bad = 2
        case neutral = 3
        case good = 4
        case veryGood = 5
        
        var emoji: String {
            switch self {
            case .veryBad: return "😢"
            case .bad: return "😔"
            case .neutral: return "😐"
            case .good: return "😊"
            case .veryGood: return "😄"
            }
        }
    }
    
    init(date: Date = Date(), count: Int = 1, note: String = "", mood: Mood? = nil) {
        self.id = UUID()
        self.date = date
        self.count = count
        self.note = note
        self.mood = mood
        self.photoData = nil
        self.timeSpent = 0
    }
}

