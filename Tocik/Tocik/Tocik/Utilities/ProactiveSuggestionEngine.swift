//
//  ProactiveSuggestionEngine.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 主动推送建议引擎（优化20）
//

import Foundation
import SwiftUI
import Combine

/// 主动推送引擎 - 从"事后分析"升级到"实时指导"
@MainActor
class ProactiveSuggestionEngine: ObservableObject {
    static let shared = ProactiveSuggestionEngine()
    
    @Published var activeSuggestion: ProactiveSuggestion?
    @Published var suggestionQueue: [ProactiveSuggestion] = []
    
    // 推送规则
    private var rules: [ProactiveTrigger] = []
    
    // 冷却时间（避免过度推送）
    private var lastPushTime: Date?
    private let minPushInterval: TimeInterval = 1800 // 30分钟
    
    init() {
        setupRules()
    }
    
    /// 设置触发规则
    private func setupRules() {
        rules = [
            // 规则1: 连续低专注度
            ProactiveTrigger(
                id: "consecutive_low_focus",
                condition: { context in
                    context.consecutiveLowFocusCount >= 3
                },
                suggestionGenerator: { context in
                    ProactiveSuggestion(
                        title: "专注度持续下降",
                        body: "连续3个番茄钟专注度<60分，建议休息10分钟或调整环境",
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
                id: "habit_due_reminder",
                condition: { context in
                    !context.pendingHabitsToday.isEmpty
                },
                suggestionGenerator: { context in
                    let habit = context.pendingHabitsToday.first!
                    return ProactiveSuggestion(
                        title: "\(habit.name)待打卡",
                        body: "已坚持\(habit.getCurrentStreak())天，别让连续中断！",
                        type: .reminder,
                        priority: .medium,
                        action: .checkHabit(habit)
                    )
                }
            ),
            
            // 规则4: 考试倒计时
            ProactiveTrigger(
                id: "exam_countdown",
                condition: { context in
                    context.urgentExams.contains(where: { $0.daysRemaining() == 7 })
                },
                suggestionGenerator: { context in
                    let exam = context.urgentExams.first(where: { $0.daysRemaining() == 7 })!
                    return ProactiveSuggestion(
                        title: "考试一周倒计时",
                        body: "\(exam.examName)还剩7天，建议每天2小时专项复习",
                        type: .alert,
                        priority: .high,
                        action: .openExamPrep(exam)
                    )
                }
            ),
            
            // 规则5: 学习时长目标达成
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
    }
    
    /// 检查并触发建议
    func checkAndTrigger(context: ProactiveContext) {
        // 冷却时间检查
        if let lastPush = lastPushTime,
           Date().timeIntervalSince(lastPush) < minPushInterval {
            return
        }
        
        // 遍历规则
        for rule in rules {
            if rule.condition(context) {
                let suggestion = rule.suggestionGenerator(context)
                
                // 添加到队列
                suggestionQueue.append(suggestion)
                
                // 高优先级立即显示
                if suggestion.priority == .high {
                    activeSuggestion = suggestion
                    lastPushTime = Date()
                    
                    // 发送通知
                    if context.allowNotification {
                        sendNotification(suggestion)
                    }
                }
                
                break // 一次只触发一个规则
            }
        }
    }
    
    /// 发送系统通知
    private func sendNotification(_ suggestion: ProactiveSuggestion) {
        NotificationManager.shared.schedulePomodoroNotification(
            title: suggestion.title,
            body: suggestion.body,
            after: 1
        )
    }
    
    /// 清除建议
    func dismissSuggestion() {
        activeSuggestion = nil
    }
    
    /// 执行建议动作
    func executeSuggestionAction(_ action: SuggestionAction) {
        print("🎯 执行建议动作: \(action)")
        // 具体实现由UI层处理
    }
}

// 注：以下数据结构已移至 ProactiveSource.swift
// 为避免重复定义，请使用 ProactiveSource 中定义的：
// - ProactiveTrigger
// - ProactiveSuggestion
// - SuggestionAction
// - ProactiveContext

