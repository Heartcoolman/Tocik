//
//  SuggestionEngine.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 智能建议引擎
//

import Foundation
import SwiftData

@MainActor
class SuggestionEngine {
    // 生成智能建议
    static func generateSuggestions(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        wrongQuestions: [WrongQuestion],
        goals: [Goal],
        context: ModelContext
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
        
        // 插入数据库
        for suggestion in suggestions {
            context.insert(suggestion)
        }
        
        return suggestions
    }
    
    // 时间管理建议
    private static func generateTimeManagementSuggestions(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 检查今日番茄钟数量
        let todaySessions = pomodoroSessions.filter {
            Calendar.current.isDateInToday($0.startTime)
        }
        
        if todaySessions.isEmpty && Date().timeIntervalSince1970 > Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 + 3600 * 10 {
            suggestions.append(SmartSuggestion(
                suggestionType: .timeManagement,
                title: "今日还未开始学习",
                content: "建议开始第一个番茄钟，即使只是15分钟也能建立学习势头",
                priority: .medium,
                actionType: .createTodo
            ))
        }
        
        // 检查待办事项数量
        let highPriorityTodos = todos.filter { !$0.isCompleted && ($0.priority == .high || $0.priority == .urgent) }
        if highPriorityTodos.count >= 5 {
            suggestions.append(SmartSuggestion(
                suggestionType: .timeManagement,
                title: "高优先级任务较多",
                content: "您有\(highPriorityTodos.count)个高优先级任务，建议使用番茄钟技术逐个击破",
                priority: .high,
                actionType: .adjustSchedule
            ))
        }
        
        return suggestions
    }
    
    // 学习计划建议
    private static func generateStudyPlanSuggestions(
        wrongQuestions: [WrongQuestion]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 分析错题分布
        let subjectDistribution = Dictionary(grouping: wrongQuestions.filter { $0.masteryLevel != .mastered }) { $0.subject }
        
        for (subject, questions) in subjectDistribution where questions.count >= 3 {
            suggestions.append(SmartSuggestion(
                suggestionType: .studyPlan,
                title: "\(subject)错题较多",
                content: "您在\(subject)有\(questions.count)道未掌握的错题，建议制定专项复习计划",
                priority: questions.count >= 5 ? .high : .medium,
                actionType: .reviewWrongQuestions
            ))
        }
        
        return suggestions
    }
    
    // 习惯改善建议
    private static func generateHabitSuggestions(
        habits: [Habit]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        for habit in habits {
            let streak = habit.getCurrentStreak()
            
            // 庆祝里程碑
            if streak == 7 || streak == 21 || streak == 66 || streak == 100 {
                suggestions.append(SmartSuggestion(
                    suggestionType: .habitImprovement,
                    title: "🎉 习惯里程碑",
                    content: "恭喜！「\(habit.name)」已连续坚持\(streak)天，继续保持！",
                    priority: .low
                ))
            }
            
            // 提醒中断风险
            if streak >= 7 && habit.records.last?.date.timeIntervalSinceNow ?? -86400 < -86400 {
                suggestions.append(SmartSuggestion(
                    suggestionType: .habitImprovement,
                    title: "习惯连续记录即将中断",
                    content: "「\(habit.name)」已连续\(streak)天，今天别忘了打卡",
                    priority: .high
                ))
            }
        }
        
        return suggestions
    }
    
    // 目标设定建议
    private static func generateGoalSuggestions(
        goals: [Goal]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        let activeGoals = goals.filter { !$0.isArchived }
        
        // 建议设定目标
        if activeGoals.isEmpty {
            suggestions.append(SmartSuggestion(
                suggestionType: .goalSetting,
                title: "建议设定学习目标",
                content: "设定明确的目标能提高学习效率和动力",
                priority: .medium,
                actionType: .setGoal
            ))
        }
        
        // 检查目标进度
        for goal in activeGoals {
            let progress = goal.overallProgress()
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: goal.endDate).day ?? 0
            
            if progress < 50 && daysLeft < 30 {
                suggestions.append(SmartSuggestion(
                    suggestionType: .goalSetting,
                    title: "目标进度落后",
                    content: "「\(goal.title)」进度为\(Int(progress))%，距离截止还有\(daysLeft)天，需要加快进度",
                    priority: .high,
                    relatedItemId: goal.id,
                    actionType: .adjustSchedule
                ))
            }
        }
        
        return suggestions
    }
    
    // 复习提醒
    private static func generateReviewReminders(
        wrongQuestions: [WrongQuestion]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        let needReview = wrongQuestions.filter { $0.nextReviewDate <= Date() && $0.masteryLevel != .mastered }
        
        if needReview.count >= 5 {
            suggestions.append(SmartSuggestion(
                suggestionType: .review,
                title: "有\(needReview.count)道错题待复习",
                content: "建议抽出时间复习这些错题，巩固知识点",
                priority: .medium,
                actionType: .reviewWrongQuestions
            ))
        }
        
        return suggestions
    }
}

