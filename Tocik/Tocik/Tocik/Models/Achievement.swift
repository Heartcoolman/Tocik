//
//  Achievement.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 成就系统
//

import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var achievementId: String // 唯一标识符
    var name: String
    var achievementDescription: String
    var icon: String
    var category: AchievementCategory
    var requirement: Int // 达成要求的数量
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Int // 当前进度
    var rewardPoints: Int // 奖励积分
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case pomodoro = "番茄钟"
        case todo = "待办事项"
        case habit = "习惯追踪"
        case study = "学习进度"
        case streak = "连续打卡"
        case special = "特殊成就"
        
        var colorHex: String {
            switch self {
            case .pomodoro: return "#FF6B6B"
            case .todo: return "#4ECDC4"
            case .habit: return "#A78BFA"
            case .study: return "#8B5CF6"
            case .streak: return "#F59E0B"
            case .special: return "#EC4899"
            }
        }
    }
    
    init(achievementId: String, name: String, achievementDescription: String, icon: String, category: AchievementCategory, requirement: Int, rewardPoints: Int = 10) {
        self.id = UUID()
        self.achievementId = achievementId
        self.name = name
        self.achievementDescription = achievementDescription
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.isUnlocked = false
        self.unlockedDate = nil
        self.progress = 0
        self.rewardPoints = rewardPoints
    }
    
    // 更新进度
    func updateProgress(_ newProgress: Int) {
        self.progress = newProgress
        if progress >= requirement && !isUnlocked {
            unlock()
        }
    }
    
    // 解锁成就
    func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
    
    // 进度百分比
    var progressPercentage: Double {
        return min(Double(progress) / Double(requirement), 1.0)
    }
    
    // 预设成就
    static func createDefaultAchievements() -> [Achievement] {
        return [
            // 番茄钟成就
            Achievement(achievementId: "pomodoro_first", name: "初入职场", achievementDescription: "完成第1个番茄钟", icon: "🍅", category: .pomodoro, requirement: 1, rewardPoints: 5),
            Achievement(achievementId: "pomodoro_10", name: "小试牛刀", achievementDescription: "完成10个番茄钟", icon: "🔥", category: .pomodoro, requirement: 10, rewardPoints: 10),
            Achievement(achievementId: "pomodoro_50", name: "勤勉之星", achievementDescription: "完成50个番茄钟", icon: "⭐️", category: .pomodoro, requirement: 50, rewardPoints: 25),
            Achievement(achievementId: "pomodoro_100", name: "专注大师", achievementDescription: "完成100个番茄钟", icon: "👑", category: .pomodoro, requirement: 100, rewardPoints: 50),
            
            // 待办事项成就
            Achievement(achievementId: "todo_first", name: "开始行动", achievementDescription: "完成第1个待办", icon: "✅", category: .todo, requirement: 1, rewardPoints: 5),
            Achievement(achievementId: "todo_50", name: "执行力强", achievementDescription: "完成50个待办", icon: "💪", category: .todo, requirement: 50, rewardPoints: 20),
            Achievement(achievementId: "todo_100", name: "行动派", achievementDescription: "完成100个待办", icon: "🚀", category: .todo, requirement: 100, rewardPoints: 40),
            
            // 习惯追踪成就
            Achievement(achievementId: "habit_7days", name: "七日之约", achievementDescription: "连续打卡7天", icon: "📅", category: .streak, requirement: 7, rewardPoints: 15),
            Achievement(achievementId: "habit_21days", name: "习惯养成", achievementDescription: "连续打卡21天", icon: "🌱", category: .streak, requirement: 21, rewardPoints: 30),
            Achievement(achievementId: "habit_66days", name: "习惯大师", achievementDescription: "连续打卡66天", icon: "🏆", category: .streak, requirement: 66, rewardPoints: 100),
            Achievement(achievementId: "habit_100days", name: "百日坚持", achievementDescription: "连续打卡100天", icon: "💯", category: .streak, requirement: 100, rewardPoints: 200),
            
            // 学习成就
            Achievement(achievementId: "flashcard_100", name: "记忆高手", achievementDescription: "复习100张闪卡", icon: "🧠", category: .study, requirement: 100, rewardPoints: 30),
            Achievement(achievementId: "note_10", name: "勤于记录", achievementDescription: "创建10篇笔记", icon: "📝", category: .study, requirement: 10, rewardPoints: 15),
            Achievement(achievementId: "wrong_50", name: "错题终结者", achievementDescription: "掌握50道错题", icon: "📚", category: .study, requirement: 50, rewardPoints: 40),
            
            // 特殊成就
            Achievement(achievementId: "early_bird", name: "早起的鸟儿", achievementDescription: "早上6点前完成一个番茄钟", icon: "🌅", category: .special, requirement: 1, rewardPoints: 20),
            Achievement(achievementId: "night_owl", name: "夜猫子", achievementDescription: "晚上11点后完成一个番茄钟", icon: "🦉", category: .special, requirement: 1, rewardPoints: 20),
            Achievement(achievementId: "perfect_week", name: "完美一周", achievementDescription: "一周内每天都完成至少3个番茄钟", icon: "🎯", category: .special, requirement: 7, rewardPoints: 50),
        ]
    }
}

// 用户等级系统
@Model
final class UserLevel {
    var id: UUID
    var totalPoints: Int
    var currentLevel: Int
    var currentLevelPoints: Int
    var nextLevelPoints: Int
    
    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.currentLevel = 1
        self.currentLevelPoints = 0
        self.nextLevelPoints = 100
    }
    
    // 添加积分
    func addPoints(_ points: Int) {
        totalPoints += points
        currentLevelPoints += points
        
        // 检查是否升级
        while currentLevelPoints >= nextLevelPoints {
            levelUp()
        }
    }
    
    // 升级
    private func levelUp() {
        currentLevel += 1
        currentLevelPoints -= nextLevelPoints
        // 下一级所需积分增加
        nextLevelPoints = Int(Double(nextLevelPoints) * 1.5)
    }
    
    // 当前等级进度
    var levelProgress: Double {
        return Double(currentLevelPoints) / Double(nextLevelPoints)
    }
    
    // 等级称号
    var levelTitle: String {
        switch currentLevel {
        case 1...5: return "初学者"
        case 6...10: return "学徒"
        case 11...20: return "熟练者"
        case 21...30: return "专家"
        case 31...50: return "大师"
        default: return "传奇"
        }
    }
}

