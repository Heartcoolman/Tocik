//
//  AchievementManager.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 成就管理系统
//

import Foundation
import SwiftData

@MainActor
class AchievementManager {
    // 检查并更新成就
    static func checkAchievements(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        flashCards: [FlashCard],
        notes: [Note],
        wrongQuestions: [WrongQuestion],
        achievements: [Achievement],
        userLevel: UserLevel?,
        context: ModelContext
    ) -> [Achievement] {
        var unlockedAchievements: [Achievement] = []
        
        // 番茄钟成就
        let pomodoroCount = pomodoroSessions.filter { $0.isCompleted }.count
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["pomodoro_first", "pomodoro_10", "pomodoro_50", "pomodoro_100"],
            currentProgress: pomodoroCount,
            achievements: achievements
        ))
        
        // 待办事项成就
        let completedTodos = todos.filter { $0.isCompleted }.count
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["todo_first", "todo_50", "todo_100"],
            currentProgress: completedTodos,
            achievements: achievements
        ))
        
        // 习惯连续打卡成就
        let maxStreak = habits.map { $0.getCurrentStreak() }.max() ?? 0
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["habit_7days", "habit_21days", "habit_66days", "habit_100days"],
            currentProgress: maxStreak,
            achievements: achievements
        ))
        
        // 闪卡复习成就
        let flashCardReviews = flashCards.map { $0.reviewCount }.reduce(0, +)
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["flashcard_100"],
            currentProgress: flashCardReviews,
            achievements: achievements
        ))
        
        // 笔记创建成就
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["note_10"],
            currentProgress: notes.count,
            achievements: achievements
        ))
        
        // 错题掌握成就
        let masteredQuestions = wrongQuestions.filter { $0.masteryLevel == .mastered }.count
        unlockedAchievements.append(contentsOf: checkProgressAchievements(
            achievementIds: ["wrong_50"],
            currentProgress: masteredQuestions,
            achievements: achievements
        ))
        
        // 特殊成就
        unlockedAchievements.append(contentsOf: checkSpecialAchievements(
            pomodoroSessions: pomodoroSessions,
            achievements: achievements
        ))
        
        // 给用户增加积分
        if let userLevel = userLevel {
            let totalPoints = unlockedAchievements.map { $0.rewardPoints }.reduce(0, +)
            userLevel.addPoints(totalPoints)
        }
        
        return unlockedAchievements
    }
    
    // 检查进度类成就
    private static func checkProgressAchievements(
        achievementIds: [String],
        currentProgress: Int,
        achievements: [Achievement]
    ) -> [Achievement] {
        var unlocked: [Achievement] = []
        
        for achievementId in achievementIds {
            if let achievement = achievements.first(where: { $0.achievementId == achievementId && !$0.isUnlocked }) {
                achievement.updateProgress(currentProgress)
                if achievement.isUnlocked {
                    unlocked.append(achievement)
                }
            }
        }
        
        return unlocked
    }
    
    // 检查特殊成就
    private static func checkSpecialAchievements(
        pomodoroSessions: [PomodoroSession],
        achievements: [Achievement]
    ) -> [Achievement] {
        var unlocked: [Achievement] = []
        let calendar = Calendar.current
        
        // 早起的鸟儿（早上6点前）
        let earlyBirdSessions = pomodoroSessions.filter {
            let hour = calendar.component(.hour, from: $0.startTime)
            return hour < 6 && $0.isCompleted
        }
        if !earlyBirdSessions.isEmpty,
           let achievement = achievements.first(where: { $0.achievementId == "early_bird" && !$0.isUnlocked }) {
            achievement.unlock()
            unlocked.append(achievement)
        }
        
        // 夜猫子（晚上11点后）
        let nightOwlSessions = pomodoroSessions.filter {
            let hour = calendar.component(.hour, from: $0.startTime)
            return hour >= 23 && $0.isCompleted
        }
        if !nightOwlSessions.isEmpty,
           let achievement = achievements.first(where: { $0.achievementId == "night_owl" && !$0.isUnlocked }) {
            achievement.unlock()
            unlocked.append(achievement)
        }
        
        // 完美一周（连续7天每天至少3个番茄钟）
        let last7Days = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: Date())
        }
        let perfectWeek = last7Days.allSatisfy { day in
            let daySessions = pomodoroSessions.filter {
                calendar.isDate($0.startTime, inSameDayAs: day) && $0.isCompleted
            }
            return daySessions.count >= 3
        }
        if perfectWeek,
           let achievement = achievements.first(where: { $0.achievementId == "perfect_week" && !$0.isUnlocked }) {
            achievement.unlock()
            unlocked.append(achievement)
        }
        
        return unlocked
    }
    
    // 初始化默认成就
    static func initializeDefaultAchievements(context: ModelContext) {
        let defaults = Achievement.createDefaultAchievements()
        for achievement in defaults {
            context.insert(achievement)
        }
    }
}

