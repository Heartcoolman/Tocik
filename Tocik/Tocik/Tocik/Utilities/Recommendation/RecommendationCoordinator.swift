//
//  RecommendationCoordinator.swift
//  Tocik
//
//  Created: 2025/10/24
//  重构: 统一建议协调器 - 整合所有建议来源
//

import Foundation
import SwiftData

/// 统一建议协调器 - 整合规则、AI、学习三大建议来源
@MainActor
class RecommendationCoordinator {
    static let shared = RecommendationCoordinator()
    
    private init() {}
    
    // MARK: - 统一建议生成入口
    
    /// 生成综合建议（整合所有来源）
    func generateRecommendations(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        wrongQuestions: [WrongQuestion],
        goals: [Goal],
        userProfile: UserProfile?,
        context: ModelContext
    ) -> [SmartSuggestion] {
        var allSuggestions: [SmartSuggestion] = []
        
        // 1. 基于规则的建议（本地快速生成）
        let ruleSuggestions = RuleBasedSource.generate(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits,
            wrongQuestions: wrongQuestions,
            goals: goals
        )
        allSuggestions.append(contentsOf: ruleSuggestions)
        
        // 2. 应用学习到的用户偏好过滤
        if let userProfile = userProfile {
            allSuggestions = PreferenceLearningEngine.filterByPreferences(
                suggestions: allSuggestions,
                userProfile: userProfile
            )
        }
        
        // 3. 去重
        allSuggestions = removeDuplicates(allSuggestions)
        
        // 4. 智能排序
        let rankingContext = RankingContext(
            upcomingDeadlines: todos.filter { !$0.isCompleted && $0.dueDate != nil }
                .compactMap { $0.dueDate },
            currentSchedule: [],
            historicalAcceptance: [:],
            recentSuggestions: []
        )
        allSuggestions = SuggestionRanker.rank(
            suggestions: allSuggestions,
            context: rankingContext
        )
        
        // 5. 限制数量（避免建议过多）
        let maxSuggestions = 10
        allSuggestions = Array(allSuggestions.prefix(maxSuggestions))
        
        // 6. 插入数据库
        for suggestion in allSuggestions {
            context.insert(suggestion)
        }
        
        return allSuggestions
    }
    
    // MARK: - 实时主动推送检查
    
    /// 检查是否需要主动推送建议
    func checkProactiveSuggestions(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        exams: [Exam],
        dailyGoal: Int
    ) -> ProactiveSuggestion? {
        let context = ProactiveContext(
            consecutiveLowFocusCount: calculateLowFocusCount(pomodoroSessions),
            justCompletedTask: false,
            highPriorityTasks: todos.filter { !$0.isCompleted && $0.priority.rawValue >= 3 },
            pendingHabitsToday: getPendingHabitsToday(habits),
            urgentExams: exams.filter { !$0.isFinished && $0.daysRemaining() <= 7 },
            todayPomodoros: getTodayPomodoros(pomodoroSessions),
            dailyGoal: dailyGoal,
            hasNotifiedToday: false,
            allowNotification: true
        )
        
        return ProactiveSource.checkTriggers(context: context)
    }
    
    // MARK: - 记录反馈
    
    /// 记录用户对建议的反馈
    func recordFeedback(
        suggestionId: UUID,
        suggestionType: String,
        action: SuggestionFeedback.FeedbackAction,
        userProfile: UserProfile?,
        context: ModelContext
    ) {
        guard let userProfile = userProfile else { return }
        
        PreferenceLearningEngine.recordFeedback(
            suggestionId: suggestionId,
            suggestionType: suggestionType,
            feedback: action,
            userProfile: userProfile,
            context: context
        )
    }
    
    // MARK: - 辅助方法
    
    private func removeDuplicates(_ suggestions: [SmartSuggestion]) -> [SmartSuggestion] {
        var seen = Set<String>()
        return suggestions.filter { suggestion in
            let key = "\(suggestion.suggestionType.rawValue)_\(suggestion.title)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
    
    private func calculateLowFocusCount(_ sessions: [PomodoroSession]) -> Int {
        let recent = sessions.suffix(5)
        return recent.filter { $0.focusScore < 60 }.count
    }
    
    private func getPendingHabitsToday(_ habits: [Habit]) -> [Habit] {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.filter { habit in
            !habit.records.contains { record in
                Calendar.current.isDate(record.date, inSameDayAs: today)
            }
        }
    }
    
    private func getTodayPomodoros(_ sessions: [PomodoroSession]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter { session in
            Calendar.current.isDate(session.startTime, inSameDayAs: today) && session.isCompleted
        }.count
    }
}

