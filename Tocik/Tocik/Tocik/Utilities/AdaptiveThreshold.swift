//
//  AdaptiveThreshold.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 自适应阈值管理器（优化5）
//

import Foundation

/// 智能阈值管理器 - 根据用户历史数据动态调整阈值
class AdaptiveThreshold {
    static let shared = AdaptiveThreshold()
    
    // 默认阈值（后备值）
    private let defaultThresholds: [String: Double] = [
        "weeklyPomodoros": 10,
        "dailyPomodoros": 3,
        "todoCompletionRate": 0.7,
        "habitCheckInRate": 0.8,
        "focusScore": 70,
        "weeklyStudyHours": 5
    ]
    
    // 用户个性化阈值
    private var userThresholds: [String: Double] = [:]
    
    /// 获取自适应阈值
    func getThreshold(for metric: String, historicalData: [Double]) -> Double {
        // 如果有缓存的个性化阈值，使用它
        if let cached = userThresholds[metric] {
            return cached
        }
        
        // 如果数据不足，使用默认值
        guard historicalData.count >= 7 else {
            return defaultThresholds[metric] ?? 0
        }
        
        // 基于历史数据计算
        let sorted = historicalData.sorted()
        let median = sorted[sorted.count / 2] // 中位数
        let p75 = sorted[Int(Double(sorted.count) * 0.75)] // 75分位数
        
        // 动态阈值 = 70% 中位数 + 30% 目标值
        let adaptiveThreshold = median * 0.7 + p75 * 0.3
        
        // 缓存
        userThresholds[metric] = adaptiveThreshold
        
        return adaptiveThreshold
    }
    
    /// 批量更新阈值（基于最新数据）
    func updateThresholds(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit]
    ) {
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        // 计算番茄钟阈值
        let weeklyPomodoros = calculateWeeklyPomodoros(sessions: pomodoroSessions, since: monthAgo)
        if !weeklyPomodoros.isEmpty {
            userThresholds["weeklyPomodoros"] = getThreshold(for: "weeklyPomodoros", historicalData: weeklyPomodoros)
        }
        
        // 计算完成率阈值
        let completionRates = calculateCompletionRates(todos: todos, since: monthAgo)
        if !completionRates.isEmpty {
            userThresholds["todoCompletionRate"] = getThreshold(for: "todoCompletionRate", historicalData: completionRates)
        }
        
        // 计算专注度阈值
        let focusScores = pomodoroSessions
            .filter { $0.startTime >= monthAgo && $0.isCompleted }
            .map { $0.focusScore }
        if !focusScores.isEmpty {
            userThresholds["focusScore"] = getThreshold(for: "focusScore", historicalData: focusScores)
        }
    }
    
    /// 判断是否低于阈值（带描述）
    func evaluateMetric(_ metric: String, value: Double, historicalData: [Double]) -> (isBelowThreshold: Bool, description: String) {
        let threshold = getThreshold(for: metric, historicalData: historicalData)
        let isBelowThreshold = value < threshold
        
        let description: String
        if isBelowThreshold {
            let gap = Int((threshold - value) / threshold * 100)
            description = "低于您的平均水平\(gap)%"
        } else {
            let exceed = Int((value - threshold) / threshold * 100)
            description = "超过平均水平\(exceed)%，保持得很好！"
        }
        
        return (isBelowThreshold, description)
    }
    
    // MARK: - 辅助计算
    
    private func calculateWeeklyPomodoros(sessions: [PomodoroSession], since: Date) -> [Double] {
        let weeklyGroups = Dictionary(grouping: sessions.filter { $0.startTime >= since }) { session in
            Calendar.current.component(.weekOfYear, from: session.startTime)
        }
        return weeklyGroups.values.map { Double($0.count) }
    }
    
    private func calculateCompletionRates(todos: [TodoItem], since: Date) -> [Double] {
        let weeklyGroups = Dictionary(grouping: todos.filter { $0.createdDate >= since }) { todo in
            Calendar.current.component(.weekOfYear, from: todo.createdDate)
        }
        return weeklyGroups.values.map { weekTodos in
            let completed = weekTodos.filter { $0.isCompleted }.count
            return weekTodos.isEmpty ? 0 : Double(completed) / Double(weekTodos.count)
        }
    }
}

