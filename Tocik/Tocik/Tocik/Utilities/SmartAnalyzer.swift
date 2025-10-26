//
//  SmartAnalyzer.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 智能分析引擎
//

import Foundation
import SwiftData

@MainActor
class SmartAnalyzer {
    // 分析学习模式（优化1: 带缓存）
    static func analyzeStudyPattern(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit]
    ) -> StudyPattern {
        // 检查缓存
        if let cached = AnalysisCache.shared.getCachedStudyPattern() {
            return cached
        }
        let calendar = Calendar.current
        let now = Date()
        let last30Days = calendar.date(byAdding: .day, value: -30, to: now)!
        
        // 分析最佳学习时段
        let recentSessions = pomodoroSessions.filter { $0.startTime >= last30Days }
        let hourlyPerformance = Dictionary(grouping: recentSessions) { session in
            calendar.component(.hour, from: session.startTime)
        }.mapValues { sessions in
            sessions.map { $0.focusScore }.reduce(0, +) / Double(sessions.count)
        }
        
        let bestHour = hourlyPerformance.max { $0.value < $1.value }?.key ?? 9
        
        // 分析工作效率
        let avgFocusScore = recentSessions.isEmpty ? 0 : recentSessions.map { $0.focusScore }.reduce(0, +) / Double(recentSessions.count)
        
        // 分析完成率
        let completedTodos = todos.filter { $0.isCompleted && $0.completedDate ?? Date.distantPast >= last30Days }.count
        let totalTodos = todos.filter { $0.createdDate >= last30Days }.count
        let completionRate = totalTodos > 0 ? Double(completedTodos) / Double(totalTodos) : 0
        
        // 分析习惯坚持
        let avgStreak = habits.isEmpty ? 0 : habits.map { Double($0.getCurrentStreak()) }.reduce(0, +) / Double(habits.count)
        
        let pattern = StudyPattern(
            bestStudyHour: bestHour,
            averageFocusScore: avgFocusScore,
            taskCompletionRate: completionRate,
            averageStreak: avgStreak,
            totalPomodoroCount: recentSessions.count,
            analysisDate: now
        )
        
        // 缓存结果
        AnalysisCache.shared.cacheStudyPattern(pattern)
        
        return pattern
    }
    
    // 识别知识弱点（优化1: 带缓存）
    static func identifyWeaknesses(
        wrongQuestions: [WrongQuestion],
        flashCards: [FlashCard]
    ) -> [KnowledgeWeakness] {
        // 检查缓存
        if let cached = AnalysisCache.shared.getCachedWeaknesses() {
            return cached
        }
        var weaknesses: [KnowledgeWeakness] = []
        
        // 分析错题
        let wrongBySubject = Dictionary(grouping: wrongQuestions.filter { $0.masteryLevel != .mastered }) { $0.subject }
        for (subject, questions) in wrongBySubject {
            if questions.count >= 3 {
                let avgScore = questions.map { $0.masteryScore }.reduce(0, +) / Double(questions.count)
                weaknesses.append(KnowledgeWeakness(
                    subject: subject,
                    weaknessType: .wrongQuestions,
                    severity: avgScore < 40 ? .high : avgScore < 60 ? .medium : .low,
                    itemCount: questions.count,
                    averageScore: avgScore
                ))
            }
        }
        
        // 分析闪卡
        let difficultCards = flashCards.filter { $0.accuracyRate < 0.6 && $0.reviewCount >= 3 }
        let cardsByTag = Dictionary(grouping: difficultCards) { card in
            card.tags.first ?? "未分类"
        }
        for (tag, cards) in cardsByTag {
            if cards.count >= 3 {
                let avgAccuracy = cards.map { $0.accuracyRate }.reduce(0, +) / Double(cards.count)
                weaknesses.append(KnowledgeWeakness(
                    subject: tag,
                    weaknessType: .flashCards,
                    severity: avgAccuracy < 0.4 ? .high : avgAccuracy < 0.5 ? .medium : .low,
                    itemCount: cards.count,
                    averageScore: avgAccuracy * 100
                ))
            }
        }
        
        let sortedWeaknesses = weaknesses.sorted { $0.severity.rawValue > $1.severity.rawValue }
        
        // 缓存结果
        AnalysisCache.shared.cacheWeaknesses(sortedWeaknesses)
        
        return sortedWeaknesses
    }
    
    // 计算学习效率
    static func calculateEfficiency(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        timeRange: TimeRange
    ) -> Double {
        let startDate = timeRange.startDate
        let endDate = timeRange.endDate
        
        let sessions = pomodoroSessions.filter { $0.startTime >= startDate && $0.startTime <= endDate }
        let completedTodos = todos.filter { ($0.completedDate ?? Date.distantPast) >= startDate && ($0.completedDate ?? Date.distantPast) <= endDate }
        
        guard !sessions.isEmpty else { return 0 }
        
        let totalHours = Double(sessions.count) * 0.5 // 每个番茄钟约0.5小时
        let completedCount = Double(completedTodos.count)
        
        // 效率 = 完成任务数 / 投入时间 * 平均专注度
        let avgFocus = sessions.map { $0.focusScore }.reduce(0, +) / Double(sessions.count) / 100.0
        let efficiency = (completedCount / totalHours) * avgFocus
        
        return min(efficiency * 20, 100) // 标准化到0-100
    }
}

// MARK: - 数据结构

struct StudyPattern {
    let bestStudyHour: Int
    let averageFocusScore: Double
    let taskCompletionRate: Double
    let averageStreak: Double
    let totalPomodoroCount: Int
    let analysisDate: Date
    
    var summary: String {
        """
        您的最佳学习时段是 \(bestStudyHour):00，平均专注度为 \(String(format: "%.1f", averageFocusScore))分。
        任务完成率：\(String(format: "%.1f%%", taskCompletionRate * 100))
        平均连续打卡：\(String(format: "%.1f", averageStreak))天
        30天内完成了 \(totalPomodoroCount) 个番茄钟
        """
    }
}

struct KnowledgeWeakness {
    let subject: String
    let weaknessType: WeaknessType
    let severity: Severity
    let itemCount: Int
    let averageScore: Double
    
    enum WeaknessType: String {
        case wrongQuestions = "错题"
        case flashCards = "闪卡"
        case lowScore = "低分"
    }
    
    enum Severity: Int {
        case low = 1
        case medium = 2
        case high = 3
        
        var displayName: String {
            switch self {
            case .low: return "轻微"
            case .medium: return "中等"
            case .high: return "严重"
            }
        }
        
        var colorHex: String {
            switch self {
            case .low: return "#FFD93D"
            case .medium: return "#FF9A3D"
            case .high: return "#FF6B6B"
            }
        }
    }
    
    var recommendation: String {
        switch severity {
        case .high:
            return "建议重点复习\(subject)，每天至少30分钟"
        case .medium:
            return "建议加强\(subject)的练习，每周复习2-3次"
        case .low:
            return "继续保持，定期复习即可"
        }
    }
}

struct TimeRange {
    let startDate: Date
    let endDate: Date
    
    static var lastWeek: TimeRange {
        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        return TimeRange(startDate: weekAgo, endDate: now)
    }
    
    static var lastMonth: TimeRange {
        let now = Date()
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        return TimeRange(startDate: monthAgo, endDate: now)
    }
}

