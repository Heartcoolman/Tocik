//
//  DataDigest.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v4.0 - 数据摘要生成器（将用户数据压缩成AI友好的摘要格式）
//

import Foundation

struct DataDigest {
    // 时间范围
    let period: TimePeriod
    let startDate: Date
    let endDate: Date
    
    // 各类数据摘要
    let pomodoroSummary: PomodoroDigest
    let todoSummary: TodoDigest
    let habitSummary: HabitDigest
    let patternSummary: PatternDigest
    let userProfile: UserProfileDigest?
    
    // v5.0: 新增数据摘要
    let subjectSummary: String?
    let examSummary: String?
    let noteSummary: String?
    let reviewSummary: String?
    let courseSummary: String?
    let achievementSummary: String?
    
    enum TimePeriod: String {
        case day = "今日"
        case week = "本周"
        case month = "本月"
        case quarter = "本季"
    }
    
    // 生成给AI的Prompt
    func generateAIPrompt() -> String {
        """
        ## 用户学习数据摘要 (\(period.rawValue))
        时间范围：\(formatDate(startDate)) 至 \(formatDate(endDate))
        
        ### 📊 番茄钟数据
        - 总数：\(pomodoroSummary.totalCount) 个
        - 完成率：\(String(format: "%.1f%%", pomodoroSummary.completionRate * 100))
        - 平均专注度：\(String(format: "%.1f分", pomodoroSummary.avgFocusScore))
        - 最佳时段：\(pomodoroSummary.bestHours.map { "\($0)时" }.joined(separator: ", "))
        - 中断次数：\(pomodoroSummary.totalInterruptions) 次
        
        ### ✅ 待办任务
        - 完成：\(todoSummary.completedCount)/\(todoSummary.totalCount)
        - 完成率：\(String(format: "%.1f%%", todoSummary.completionRate * 100))
        - 过期任务：\(todoSummary.overdueCount) 个
        - 高优先级：\(todoSummary.highPriorityCount) 个
        - 平均完成时间：\(todoSummary.avgCompletionTime) 分钟
        
        ### 🔥 习惯追踪
        - 活跃习惯：\(habitSummary.activeHabitsCount) 个
        - 平均连续：\(habitSummary.avgStreak) 天
        - 最长连续：\(habitSummary.maxStreak) 天
        - 本周打卡率：\(String(format: "%.1f%%", habitSummary.checkInRate * 100))
        
        ### 📈 学习模式
        - 学习时长：\(String(format: "%.1f小时", patternSummary.totalStudyHours))
        - 效率趋势：\(patternSummary.efficiencyTrend)
        - 主要学习时段：\(patternSummary.primaryStudyTime)
        - 拖延倾向：\(patternSummary.procrastinationLevel)
        
        \(userProfile != nil ? """
        ### 👤 用户画像
        - 学习风格：\(userProfile!.learningStyle)
        - 最佳学习时间：\(userProfile!.bestHours.map { "\($0)时" }.joined(separator: ", "))
        - 建议接受率：\(String(format: "%.1f%%", userProfile!.acceptanceRate * 100))
        - 偏好番茄钟时长：\(userProfile!.preferredSessionLength) 分钟
        """ : "")
        
        \(subjectSummary != nil ? """
        ### 📚 科目学习
        \(subjectSummary!)
        """ : "")
        
        \(examSummary != nil ? """
        ### 🎯 考试安排
        \(examSummary!)
        """ : "")
        
        \(noteSummary != nil ? """
        ### 📝 笔记情况
        \(noteSummary!)
        """ : "")
        
        \(reviewSummary != nil ? """
        ### 🔄 复习计划
        \(reviewSummary!)
        """ : "")
        
        \(courseSummary != nil ? """
        ### 📅 课程安排
        \(courseSummary!)
        """ : "")
        
        \(achievementSummary != nil ? """
        ### 🏆 成就进度
        \(achievementSummary!)
        """ : "")
        
        请基于以上数据：
        1. 分析用户的学习模式和趋势
        2. 识别潜在问题和改进空间（特别关注薄弱科目、临近考试、复习进度）
        3. 生成3-5条个性化建议（必须具体、可执行）
        4. 预测未来一周的学习建议
        """
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 各类摘要结构

struct PomodoroDigest {
    let totalCount: Int
    let completionRate: Double
    let avgFocusScore: Double
    let bestHours: [Int]
    let totalInterruptions: Int
}

struct TodoDigest {
    let totalCount: Int
    let completedCount: Int
    let completionRate: Double
    let overdueCount: Int
    let highPriorityCount: Int
    let avgCompletionTime: Int
}

struct HabitDigest {
    let activeHabitsCount: Int
    let avgStreak: Int
    let maxStreak: Int
    let checkInRate: Double
}

struct PatternDigest {
    let totalStudyHours: Double
    let efficiencyTrend: String // "上升", "稳定", "下降"
    let primaryStudyTime: String // "上午", "下午", "晚上"
    let procrastinationLevel: String // "低", "中", "高"
}

struct UserProfileDigest {
    let learningStyle: String
    let bestHours: [Int]
    let acceptanceRate: Double
    let preferredSessionLength: Int
}

