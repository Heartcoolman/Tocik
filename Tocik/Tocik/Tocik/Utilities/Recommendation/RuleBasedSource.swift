//
//  RuleBasedSource.swift
//  Tocik
//
//  Created: 2025/10/24
//  重构: 基于规则的建议来源（整合自 SuggestionEngine）
//

import Foundation
import SwiftData

/// 基于规则的建议生成器 - 本地快速生成，无需AI
@MainActor
class RuleBasedSource {
    
    /// 生成所有类型的建议
    static func generate(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        wrongQuestions: [WrongQuestion],
        goals: [Goal]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 时间管理建议
        suggestions.append(contentsOf: generateTimeManagementSuggestions(
            pomodoroSessions: pomodoroSessions,
            todos: todos
        ))
        
        // 学习计划建议
        suggestions.append(contentsOf: generateStudyPlanSuggestions(
            wrongQuestions: wrongQuestions
        ))
        
        // 习惯改善建议
        suggestions.append(contentsOf: generateHabitSuggestions(
            habits: habits
        ))
        
        // 目标设定建议
        suggestions.append(contentsOf: generateGoalSuggestions(
            goals: goals
        ))
        
        // 复习提醒
        suggestions.append(contentsOf: generateReviewReminders(
            wrongQuestions: wrongQuestions
        ))
        
        return suggestions
    }
    
    // MARK: - 各类型建议生成
    
    private static func generateTimeManagementSuggestions(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 检查今日番茄钟完成情况
        let today = Calendar.current.startOfDay(for: Date())
        let todaySessions = pomodoroSessions.filter {
            Calendar.current.isDate($0.startTime, inSameDayAs: today)
        }
        
        if todaySessions.count < 4 {
            suggestions.append(SmartSuggestion(
                suggestionType: .efficiency,
                title: "增加学习时长",
                content: "今天完成了\(todaySessions.count)个番茄钟，建议至少完成4个以保持学习节奏",
                priority: .high,
                actionType: .createTodo
            ))
        }
        
        // 检查逾期任务
        let overdueTodos = todos.filter {
            if let dueDate = $0.dueDate {
                return !$0.isCompleted && dueDate < Date()
            }
            return false
        }
        
        if overdueTodos.count > 0 {
            suggestions.append(SmartSuggestion(
                suggestionType: .warning,
                title: "处理逾期任务",
                content: "有\(overdueTodos.count)个任务已逾期，建议优先完成或重新规划",
                priority: .high,
                actionType: .other
            ))
        }
        
        return suggestions
    }
    
    private static func generateStudyPlanSuggestions(
        wrongQuestions: [WrongQuestion]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 检查错题积累
        if wrongQuestions.count >= 10 {
            suggestions.append(SmartSuggestion(
                suggestionType: .studyPlan,
                title: "错题复习提醒",
                content: "已积累\(wrongQuestions.count)道错题，建议开始系统复习",
                priority: .medium,
                actionType: .reviewWrongQuestions
            ))
        }
        
        return suggestions
    }
    
    private static func generateHabitSuggestions(
        habits: [Habit]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        for habit in habits {
            // 检查连续打卡情况
            let streak = habit.getCurrentStreak()
            if streak >= 7 && streak % 7 == 0 {
                suggestions.append(SmartSuggestion(
                    suggestionType: .habitImprovement,
                    title: "习惯坚持成就",
                    content: "「\(habit.name)」已连续打卡\(streak)天！继续保持！",
                    priority: .medium
                ))
            }
            
            // 检查今日是否打卡
            let today = Calendar.current.startOfDay(for: Date())
            let hasCompletedToday = habit.records.contains { record in
                Calendar.current.isDate(record.date, inSameDayAs: today)
            }
            
            if !hasCompletedToday {
                suggestions.append(SmartSuggestion(
                    suggestionType: .habitImprovement,
                    title: "习惯打卡提醒",
                    content: "今天还没有完成「\(habit.name)」，记得打卡哦",
                    priority: .medium
                ))
            }
        }
        
        return suggestions
    }
    
    private static func generateGoalSuggestions(
        goals: [Goal]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        for goal in goals {
            // 基于Goal模型的可用属性生成建议
            // 注：具体属性需要根据Goal模型调整
            suggestions.append(SmartSuggestion(
                suggestionType: .goalSetting,
                title: "目标提醒",
                content: "请关注目标「\(goal.title)」的进度",
                priority: .medium
            ))
        }
        
        return suggestions
    }
    
    private static func generateReviewReminders(
        wrongQuestions: [WrongQuestion]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 检查需要复习的错题（根据nextReviewDate）
        let needReviewQuestions = wrongQuestions.filter { question in
            return question.nextReviewDate <= Date()
        }
        
        if needReviewQuestions.count >= 3 {
            suggestions.append(SmartSuggestion(
                suggestionType: .review,
                title: "间隔复习提醒",
                content: "有\(needReviewQuestions.count)道错题到达复习时间，趁热打铁巩固一下吧",
                priority: .medium,
                actionType: .reviewWrongQuestions
            ))
        }
        
        return suggestions
    }
}

