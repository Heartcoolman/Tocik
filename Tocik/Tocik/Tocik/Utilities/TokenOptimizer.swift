//
//  TokenOptimizer.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - Token消耗优化器（优化8 + 9）
//

import Foundation

/// Token优化器 - 减少50-80% Token消耗
class TokenOptimizer {
    
    // MARK: - 优化8: 智能摘要压缩
    
    /// 压缩数据摘要，减少Token消耗
    static func compressDigest(_ digest: DataDigest, mode: CompressionMode = .smart) -> String {
        switch mode {
        case .minimal:
            return compressToMinimal(digest)
        case .smart:
            return compressToSmart(digest)
        case .full:
            return digest.generateAIPrompt()
        }
    }
    
    /// 最小压缩（仅关键指标）
    private static func compressToMinimal(_ digest: DataDigest) -> String {
        var summary: [String] = []
        
        // 只发送异常数据
        if digest.pomodoroSummary.completionRate < 0.6 {
            summary.append("⚠️ 番茄钟完成率低:\(Int(digest.pomodoroSummary.completionRate * 100))%")
        }
        
        if digest.todoSummary.overdueCount > 0 {
            summary.append("⚠️ 过期任务:\(digest.todoSummary.overdueCount)个")
        }
        
        if digest.habitSummary.checkInRate < 0.7 {
            summary.append("⚠️ 习惯打卡率:\(Int(digest.habitSummary.checkInRate * 100))%")
        }
        
        // 添加积极数据（简短）
        summary.append("✅ 本周学习\(String(format: "%.1f", digest.patternSummary.totalStudyHours))h")
        
        return summary.isEmpty ? "数据正常" : summary.joined(separator: "; ")
    }
    
    /// 智能压缩（只发送变化部分）
    private static func compressToSmart(_ digest: DataDigest) -> String {
        var compressed: [String] = []
        
        // 番茄钟：只发送关键指标
        compressed.append("番茄:\(digest.pomodoroSummary.totalCount)个(\(Int(digest.pomodoroSummary.completionRate * 100))%)")
        
        // 待办：只发送异常
        if digest.todoSummary.overdueCount > 0 || digest.todoSummary.completionRate < 0.7 {
            compressed.append("待办:\(digest.todoSummary.completedCount)/\(digest.todoSummary.totalCount),逾期\(digest.todoSummary.overdueCount)")
        }
        
        // 习惯：简化
        compressed.append("习惯:\(digest.habitSummary.activeHabitsCount)个,打卡率\(Int(digest.habitSummary.checkInRate * 100))%")
        
        // 学习模式：仅趋势
        compressed.append("趋势:\(digest.patternSummary.efficiencyTrend)")
        
        // v5.0 新数据：仅非空值
        if let subject = digest.subjectSummary, !subject.contains("无") {
            compressed.append("科目:\(subject)")
        }
        if let exam = digest.examSummary, !exam.contains("无") {
            compressed.append("考试:\(exam)")
        }
        
        return compressed.joined(separator: " | ")
    }
    
    /// 差异分析（相比上次）
    static func generateDeltaPrompt(
        current: DataDigest,
        previous: DataDigest
    ) -> String {
        var deltas: [String] = []
        
        // 番茄钟变化
        let pomodoroDelta = current.pomodoroSummary.totalCount - previous.pomodoroSummary.totalCount
        if pomodoroDelta != 0 {
            let direction = pomodoroDelta > 0 ? "增加" : "减少"
            deltas.append("番茄钟\(direction)\(abs(pomodoroDelta))个")
        }
        
        // 完成率变化
        let rateDelta = current.todoSummary.completionRate - previous.todoSummary.completionRate
        if abs(rateDelta) > 0.1 {
            let direction = rateDelta > 0 ? "提升" : "下降"
            deltas.append("完成率\(direction)\(Int(abs(rateDelta) * 100))%")
        }
        
        if deltas.isEmpty {
            return "数据变化不大，请基于当前情况给出建议"
        }
        
        return "相比上周：\(deltas.joined(separator: ", "))。请分析变化原因并给出建议。"
    }
    
    // MARK: - 优化9: 分层提示词策略
    
    enum PromptTier {
        case quick      // 快速分析 (~100 tokens)
        case standard   // 标准分析 (~300 tokens)
        case deep       // 深度分析 (~500 tokens)
    }
    
    /// 根据任务复杂度选择prompt
    static func selectPromptTier(for task: AnalysisTask) -> (systemPrompt: String, tier: PromptTier) {
        switch task.complexity {
        case .simple:
            return (quickSystemPrompt, .quick)
        case .moderate:
            return (standardSystemPrompt, .standard)
        case .complex:
            return (deepSystemPrompt, .deep)
        }
    }
    
    // 快速prompt（~50 tokens）
    private static let quickSystemPrompt = """
    学习数据分析专家。简洁回答，直接给出3条建议。
    """
    
    // 标准prompt（~150 tokens）
    private static let standardSystemPrompt = """
    你是学习助手，分析用户数据并给出建议。
    
    回答格式：
    1. 数据总结（1-2句话）
    2. 3条具体建议
    3. 下周预测
    """
    
    // 深度prompt（~500 tokens） - 使用原有的完整prompt
    private static let deepSystemPrompt = """
    你是 Tocik 学习助手，专业的学习数据分析和个性化建议智能体。
    
    核心能力：数据洞察、个性化建议、问题诊断、激励引导
    
    分析维度：学习时长、任务完成、知识掌握、习惯坚持、目标达成
    
    回答格式：
    1. 📊 数据概览
    2. 💡 关键洞察
    3. ✨ 个性化建议（3-5条）
    4. 📈 下周预测
    """
    
    /// 估算prompt token数量
    static func estimateTokens(_ text: String) -> Int {
        // 简化估算：中文约1字=1.5tokens，英文约1词=1token
        let chineseChars = text.filter { $0 >= "\u{4E00}" && $0 <= "\u{9FFF}" }.count
        let englishWords = text.split(separator: " ").count
        return Int(Double(chineseChars) * 1.5) + englishWords
    }
}

// MARK: - 数据结构

struct AnalysisTask {
    let complexity: TaskComplexity
    let dataSize: DataSize
    let userIntent: UserIntent
    
    enum TaskComplexity {
        case simple     // 快速查看
        case moderate   // 常规分析
        case complex    // 深度咨询
    }
    
    enum DataSize {
        case small      // < 7天数据
        case medium     // 7-30天
        case large      // > 30天
    }
    
    enum UserIntent {
        case quickCheck    // 快速检查
        case analysis      // 深度分析
        case consultation  // 咨询问题
    }
}

enum CompressionMode {
    case minimal    // 最小化（仅异常）
    case smart      // 智能压缩（关键指标）
    case full       // 完整数据
}

