//
//  AnomalyDetector.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 异常检测
//

import Foundation
import SwiftData

class AnomalyDetector {
    // 检测学习异常
    static func detectAnomalies(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit]
    ) -> [Anomaly] {
        var anomalies: [Anomaly] = []
        
        // 检测番茄钟突然减少
        if let pomodoroAnomaly = detectPomodoroDecrease(sessions: pomodoroSessions) {
            anomalies.append(pomodoroAnomaly)
        }
        
        // 检测待办积压
        if let todoAnomaly = detectTodoBacklog(todos: todos) {
            anomalies.append(todoAnomaly)
        }
        
        // 检测习惯中断
        if let habitAnomaly = detectHabitBreak(habits: habits) {
            anomalies.append(habitAnomaly)
        }
        
        // 检测过度工作
        if let overworkAnomaly = detectOverwork(sessions: pomodoroSessions) {
            anomalies.append(overworkAnomaly)
        }
        
        return anomalies.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
    
    // 检测番茄钟数量突然减少
    private static func detectPomodoroDecrease(sessions: [PomodoroSession]) -> Anomaly? {
        let calendar = Calendar.current
        let now = Date()
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
        let previousWeek = calendar.date(byAdding: .day, value: -14, to: now)!
        
        let lastWeekSessions = sessions.filter { $0.startTime >= lastWeek }.count
        let previousWeekSessions = sessions.filter { $0.startTime >= previousWeek && $0.startTime < lastWeek }.count
        
        guard previousWeekSessions > 0 else { return nil }
        
        let decreaseRate = Double(previousWeekSessions - lastWeekSessions) / Double(previousWeekSessions)
        
        if decreaseRate > 0.5 {
            return Anomaly(
                type: .productivityDecrease,
                severity: .high,
                title: "学习时间大幅减少",
                description: "上周番茄钟数量比前一周减少了\(Int(decreaseRate * 100))%",
                recommendation: "检查是否有外部因素影响，调整学习计划"
            )
        }
        
        return nil
    }
    
    // 检测待办积压
    private static func detectTodoBacklog(todos: [TodoItem]) -> Anomaly? {
        let overdueTodos = todos.filter {
            if let dueDate = $0.dueDate {
                return !$0.isCompleted && dueDate < Date()
            }
            return false
        }
        
        if overdueTodos.count >= 5 {
            return Anomaly(
                type: .taskBacklog,
                severity: overdueTodos.count >= 10 ? .high : .medium,
                title: "待办任务积压",
                description: "您有\(overdueTodos.count)个已过期的待办任务",
                recommendation: "建议重新评估优先级，必要时推迟或删除部分任务"
            )
        }
        
        return nil
    }
    
    // 检测习惯中断
    private static func detectHabitBreak(habits: [Habit]) -> Anomaly? {
        let brokenHabits = habits.filter { habit in
            let streak = habit.getCurrentStreak()
            return streak == 0 && habit.records.count >= 7
        }
        
        if brokenHabits.count >= 2 {
            return Anomaly(
                type: .habitBreak,
                severity: .medium,
                title: "多个习惯中断",
                description: "\(brokenHabits.count)个习惯的连续记录已中断",
                recommendation: "尝试从最重要的习惯开始重新建立，降低目标以提高成功率"
            )
        }
        
        return nil
    }
    
    // 检测过度工作
    private static func detectOverwork(sessions: [PomodoroSession]) -> Anomaly? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todaySessions = sessions.filter {
            calendar.isDate($0.startTime, inSameDayAs: today)
        }
        
        if todaySessions.count >= 12 {
            return Anomaly(
                type: .overwork,
                severity: .medium,
                title: "今日工作时间过长",
                description: "今天已完成\(todaySessions.count)个番茄钟（约\(todaySessions.count / 2)小时）",
                recommendation: "注意休息，避免过度疲劳影响学习效果"
            )
        }
        
        return nil
    }
}

// MARK: - 数据结构

struct Anomaly: Identifiable {
    let id = UUID()
    let type: AnomalyType
    let severity: Severity
    let title: String
    let description: String
    let recommendation: String
    
    enum AnomalyType {
        case productivityDecrease
        case taskBacklog
        case habitBreak
        case overwork
        case inefficiency
    }
    
    enum Severity: Int {
        case low = 1
        case medium = 2
        case high = 3
        
        var icon: String {
            switch self {
            case .low: return "exclamationmark.circle"
            case .medium: return "exclamationmark.triangle"
            case .high: return "exclamationmark.octagon"
            }
        }
        
        var colorHex: String {
            switch self {
            case .low: return "#FFD93D"
            case .medium: return "#FF9A3D"
            case .high: return "#FF6B6B"
            }
        }
        
        var displayName: String {
            switch self {
            case .low: return "低"
            case .medium: return "中"
            case .high: return "高"
            }
        }
    }
}

