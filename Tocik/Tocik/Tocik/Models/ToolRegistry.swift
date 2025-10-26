//
//  ToolRegistry.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/24.
//  统一的工具注册表 - 消除重复定义
//

import SwiftUI

struct ToolRegistry {
    // MARK: - 核心工具 (6个)
    static let coreTools: [ToolItem] = [
        ToolItem(id: "pomodoro", name: "番茄时钟", icon: "timer", color: Theme.pomodoroColor),
        ToolItem(id: "todo", name: "待办事项", icon: "checklist", color: Theme.todoColor),
        ToolItem(id: "timetable", name: "课程表", icon: "calendar.day.timeline.left", color: Theme.courseColor),
        ToolItem(id: "calendar", name: "日历", icon: "calendar", color: Theme.calendarColor),
        ToolItem(id: "habit", name: "习惯追踪", icon: "chart.line.uptrend.xyaxis", color: Theme.habitColor),
        ToolItem(id: "goal", name: "目标OKR", icon: "target", color: Color(hex: "#A78BFA"))
    ]
    
    // MARK: - 学习工具 (5个)
    static let studyTools: [ToolItem] = [
        ToolItem(id: "flashcard", name: "学习闪卡", icon: "rectangle.stack.fill", color: Color(hex: "#4A90E2")),
        ToolItem(id: "note", name: "笔记", icon: "note.text", color: Theme.noteColor),
        ToolItem(id: "wrong-question", name: "错题本", icon: "exclamationmark.triangle.fill", color: Color(hex: "#FF6B6B")),
        ToolItem(id: "study-progress", name: "学习进度", icon: "chart.bar", color: Color(hex: "#4ECDC4")),
        ToolItem(id: "inspiration", name: "灵感收集", icon: "lightbulb.fill", color: Color(hex: "#FFD93D"))
    ]
    
    // MARK: - 信息工具 (2个) - 学习专用
    static let infoTools: [ToolItem] = [
        ToolItem(id: "countdown", name: "考试倒计时", icon: "hourglass", color: Theme.countdownColor),
        ToolItem(id: "stats", name: "学习统计", icon: "chart.bar.fill", color: Theme.statsColor)
    ]
    
    // MARK: - 内容工具 (2个)
    static let contentTools: [ToolItem] = [
        ToolItem(id: "reader", name: "阅读器", icon: "book.fill", color: Theme.readerColor),
        ToolItem(id: "voice", name: "语音备忘", icon: "mic.fill", color: Color(hex: "#EF4444"))
    ]
    
    // MARK: - 辅助工具 (3个) - 学习辅助
    static let utilityTools: [ToolItem] = [
        ToolItem(id: "calculator", name: "计算器", icon: "function", color: Theme.calculatorColor),
        ToolItem(id: "converter", name: "单位换算", icon: "arrow.left.arrow.right", color: Theme.converterColor),
        ToolItem(id: "focus", name: "专注模式", icon: "headphones", color: Theme.focusColor)
    ]
    
    // MARK: - 学科工具 (7个) - 新增学习专属功能
    static let subjectTools: [ToolItem] = [
        ToolItem(id: "subject", name: "科目管理", icon: "books.vertical.fill", color: Color(hex: "#F472B6")),
        ToolItem(id: "exam", name: "考试管理", icon: "doc.text.fill", color: Color(hex: "#FF6B9D")),
        ToolItem(id: "knowledge-map", name: "知识图谱", icon: "network", color: Color(hex: "#4ECDC4")),
        ToolItem(id: "review-planner", name: "复习计划", icon: "arrow.triangle.2.circlepath", color: Color(hex: "#A78BFA")),
        ToolItem(id: "study-journal", name: "学习日志", icon: "book.pages.fill", color: Color(hex: "#FBBF24")),
        ToolItem(id: "qa-assistant", name: "答疑助手", icon: "questionmark.bubble.fill", color: Color(hex: "#8B5CF6")),
        ToolItem(id: "leaderboard", name: "学习排行", icon: "chart.bar.xaxis", color: Color(hex: "#F59E0B"))
    ]
    
    // MARK: - 智能功能工具 (6个)
    static let intelligentTools: [ToolItem] = [
        ToolItem(id: "ai-assistant", name: "AI助手", icon: "brain", color: .purple),
        ToolItem(id: "achievement", name: "成就系统", icon: "trophy.fill", color: .yellow),
        ToolItem(id: "learning-path", name: "学习路径", icon: "map", color: .blue),
        ToolItem(id: "personal-growth", name: "个人成长", icon: "chart.line.uptrend.xyaxis", color: .green),
        ToolItem(id: "search", name: "全局搜索", icon: "magnifyingglass", color: .orange),
        ToolItem(id: "prediction", name: "趋势预测", icon: "chart.xyaxis.line", color: .cyan)
    ]
    
    // MARK: - 便捷方法
    
    /// 根据 category 获取工具列表
    static func tools(for category: String) -> [ToolItem] {
        switch category {
        case "core":
            return coreTools
        case "study":
            return studyTools
        case "info":
            return infoTools
        case "content":
            return contentTools
        case "utility":
            return utilityTools
        case "subject":
            return subjectTools
        case "intelligent":
            return intelligentTools
        default:
            return []
        }
    }
    
    /// 根据 ID 获取单个工具
    static func tool(for id: String) -> ToolItem? {
        return allTools.first { $0.id == id }
    }
    
    /// 所有工具的扁平列表
    static var allTools: [ToolItem] {
        coreTools + studyTools + subjectTools + intelligentTools + contentTools + utilityTools + infoTools
    }
}

