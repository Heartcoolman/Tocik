//
//  AnalysisHistory.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 历史分析结果管理器（优化10）
//

import Foundation
import SwiftData

/// 历史分析管理 - 建立AI的"记忆"，让建议更连贯
@MainActor
class AnalysisHistory {
    static let shared = AnalysisHistory()
    
    // 历史洞察记录
    private var pastInsights: [HistoricalInsight] = []
    
    // 最大保存数量
    private let maxHistoryCount = 10
    
    /// 添加新的分析结果
    func recordInsight(
        suggestions: [SmartSuggestion],
        analysisResult: LocalAnalysisResult,
        aiResponse: String?
    ) {
        let insight = HistoricalInsight(
            date: Date(),
            suggestions: suggestions.map { $0.content },
            keyMetrics: extractKeyMetrics(from: analysisResult),
            aiSummary: aiResponse?.prefix(500).description ?? "",
            userActions: [] // 将在用户反馈时填充
        )
        
        pastInsights.append(insight)
        
        // 限制数量
        if pastInsights.count > maxHistoryCount {
            pastInsights.removeFirst()
        }
        
        print("📚 已记录分析历史，共\(pastInsights.count)条")
    }
    
    /// 获取上次分析的对比
    func getLastInsight() -> HistoricalInsight? {
        return pastInsights.last
    }
    
    /// 生成连续性分析prompt
    func enhancePromptWithHistory(baseDigest: DataDigest) -> String {
        guard let lastInsight = pastInsights.last,
              Date().timeIntervalSince(lastInsight.date) < 604800 else { // 7天内
            return baseDigest.generateAIPrompt()
        }
        
        let basePrompt = baseDigest.generateAIPrompt()
        
        let historyContext = """
        
        ## 📜 上次分析回顾（\(formatDate(lastInsight.date))）
        
        **上次给出的建议：**
        \(lastInsight.suggestions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        **关键指标对比：**
        \(lastInsight.keyMetrics)
        
        **用户执行情况：**
        \(lastInsight.userActions.isEmpty ? "待观察" : lastInsight.userActions.joined(separator: ", "))
        
        ## 🎯 本次分析重点
        请重点关注：
        1. 用户是否采纳了上次建议？效果如何？
        2. 哪些指标有改善？哪些仍需加强？
        3. 基于执行反馈，调整新的建议策略
        4. 避免重复无效的建议
        
        ---
        
        \(basePrompt)
        """
        
        return historyContext
    }
    
    /// 记录用户行动
    func recordUserAction(action: String) {
        if var lastInsight = pastInsights.last {
            lastInsight.userActions.append(action)
            pastInsights[pastInsights.count - 1] = lastInsight
        }
    }
    
    /// 分析趋势变化
    func analyzeTrend(metric: String) -> TrendAnalysis? {
        guard pastInsights.count >= 3 else { return nil }
        
        let recentValues = pastInsights.suffix(3).compactMap { insight -> Double? in
            // 从keyMetrics中提取特定指标
            // 简化实现
            return nil
        }
        
        guard recentValues.count >= 3 else { return nil }
        
        let trend: TrendAnalysis.TrendDirection
        if recentValues[2] > recentValues[1] && recentValues[1] > recentValues[0] {
            trend = .improving
        } else if recentValues[2] < recentValues[1] && recentValues[1] < recentValues[0] {
            trend = .declining
        } else {
            trend = .stable
        }
        
        return TrendAnalysis(metric: metric, trend: trend, values: recentValues)
    }
    
    // MARK: - 辅助方法
    
    private func extractKeyMetrics(from result: LocalAnalysisResult) -> String {
        var metrics: [String] = []
        
        if let pattern = result.studyPattern {
            metrics.append("番茄钟:\(pattern.totalPomodoroCount)个")
            metrics.append("完成率:\(Int(pattern.taskCompletionRate * 100))%")
            metrics.append("专注度:\(Int(pattern.averageFocusScore))分")
        }
        
        metrics.append("弱点:\(result.weaknesses.count)个")
        metrics.append("异常:\(result.anomalies.count)个")
        
        return metrics.joined(separator: ", ")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - 数据结构

struct HistoricalInsight {
    let date: Date
    let suggestions: [String]
    let keyMetrics: String
    let aiSummary: String
    var userActions: [String]
}

struct TrendAnalysis {
    let metric: String
    let trend: TrendDirection
    let values: [Double]
    
    enum TrendDirection {
        case improving
        case stable
        case declining
    }
}

