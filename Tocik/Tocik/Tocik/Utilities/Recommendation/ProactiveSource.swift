//
//  ProactiveSource.swift
//  Tocik
//
//  Created: 2025/10/24
//  重构: 主动推送建议来源（整合自 ProactiveSuggestionEngine）
//

import Foundation
import SwiftUI

/// 主动推送建议生成器 - 实时监控，主动提醒
@MainActor
class ProactiveSource {
    
    // 推送规则集
    private static let triggers: [ProactiveTrigger] = [
        // 规则1: 连续低专注度
        ProactiveTrigger(
            id: "consecutive_low_focus",
            condition: { context in
                context.consecutiveLowFocusCount >= 3
            },
            suggestionGenerator: { context in
                ProactiveSuggestion(
                    title: "专注度持续下降",
                    body: "连续\(context.consecutiveLowFocusCount)个番茄钟专注度<60分，建议休息10分钟或调整环境",
                    type: .alert,
                    priority: .high,
                    action: .suggestBreak
                )
            }
        ),
        
        // 规则2: 任务完成后推荐
        ProactiveTrigger(
            id: "task_completed_next",
            condition: { context in
                context.justCompletedTask && !context.highPriorityTasks.isEmpty
            },
            suggestionGenerator: { context in
                let nextTask = context.highPriorityTasks.first!
                return ProactiveSuggestion(
                    title: "完成得很棒！",
                    body: "建议继续完成：\(nextTask.title)",
                    type: .encouragement,
                    priority: .medium,
                    action: .startTask(nextTask)
                )
            }
        ),
        
        // 规则3: 习惯打卡提醒
        ProactiveTrigger(
            id: "habit_reminder",
            condition: { context in
                !context.pendingHabitsToday.isEmpty
            },
            suggestionGenerator: { context in
                let habit = context.pendingHabitsToday.first!
                return ProactiveSuggestion(
                    title: "别忘了打卡",
                    body: "今天还没完成「\(habit.name)」哦",
                    type: .reminder,
                    priority: .medium,
                    action: .checkHabit(habit)
                )
            }
        ),
        
        // 规则4: 紧急考试提醒
        ProactiveTrigger(
            id: "urgent_exam",
            condition: { context in
                !context.urgentExams.isEmpty
            },
            suggestionGenerator: { context in
                let exam = context.urgentExams.first!
                return ProactiveSuggestion(
                    title: "考试临近！",
                    body: "「\(exam.examName)」还有\(exam.daysRemaining())天，开始准备吧",
                    type: .alert,
                    priority: .high,
                    action: .openExamPrep(exam)
                )
            }
        ),
        
        // 规则5: 每日目标达成庆祝
        ProactiveTrigger(
            id: "daily_goal_achieved",
            condition: { context in
                context.todayPomodoros >= context.dailyGoal && !context.hasNotifiedToday
            },
            suggestionGenerator: { context in
                ProactiveSuggestion(
                    title: "🎉 今日目标达成！",
                    body: "完成\(context.todayPomodoros)个番茄钟，超过每日目标！",
                    type: .celebration,
                    priority: .low,
                    action: .showAchievement
                )
            }
        )
    ]
    
    /// 检查并生成主动建议
    static func checkTriggers(context: ProactiveContext) -> ProactiveSuggestion? {
        // 遍历所有规则
        for trigger in triggers {
            if trigger.condition(context) {
                return trigger.suggestionGenerator(context)
            }
        }
        return nil
    }
}

// MARK: - 数据结构

struct ProactiveTrigger {
    let id: String
    let condition: (ProactiveContext) -> Bool
    let suggestionGenerator: (ProactiveContext) -> ProactiveSuggestion
}

struct ProactiveSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let type: SuggestionType
    let priority: Priority
    let action: SuggestionAction
    let timestamp = Date()
    
    enum SuggestionType {
        case alert          // 警告
        case reminder       // 提醒
        case encouragement  // 鼓励
        case celebration    // 庆祝
    }
    
    enum Priority {
        case high
        case medium
        case low
    }
}

enum SuggestionAction {
    case suggestBreak
    case startTask(TodoItem)
    case checkHabit(Habit)
    case openExamPrep(Exam)
    case showAchievement
}

struct ProactiveContext {
    let consecutiveLowFocusCount: Int
    let justCompletedTask: Bool
    let highPriorityTasks: [TodoItem]
    let pendingHabitsToday: [Habit]
    let urgentExams: [Exam]
    let todayPomodoros: Int
    let dailyGoal: Int
    let hasNotifiedToday: Bool
    let allowNotification: Bool
}

