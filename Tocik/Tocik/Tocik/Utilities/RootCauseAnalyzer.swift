//
//  RootCauseAnalyzer.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 异常根因分析器（优化11）
//

import Foundation

/// 根因分析器 - 从"发现问题"升级到"解释问题"
class RootCauseAnalyzer {
    
    /// 分析异常的根本原因
    static func analyzeRootCause(
        _ anomaly: Anomaly,
        context: RootCauseContext
    ) -> RootCause {
        var possibleCauses: [Cause] = []
        var confidence: Double = 0.0
        
        switch anomaly.type {
        case .productivityDecrease:
            possibleCauses = analyzeProductivityDecrease(context: context)
            
        case .habitBreak:
            possibleCauses = analyzeHabitBreak(context: context)
            
        case .taskBacklog:
            possibleCauses = analyzeTodoBacklog(context: context)
            
        case .overwork:
            possibleCauses = analyzeOverwork(context: context)
        
        case .inefficiency:
            possibleCauses = []
        }
        
        // 计算整体置信度
        confidence = possibleCauses.isEmpty ? 0 : possibleCauses.map { $0.confidence }.reduce(0, +) / Double(possibleCauses.count)
        
        return RootCause(
            anomaly: anomaly,
            causes: possibleCauses.sorted { $0.confidence > $1.confidence },
            overallConfidence: confidence,
            recommendation: generateRecommendation(for: possibleCauses)
        )
    }
    
    // MARK: - 具体分析
    
    /// 分析生产力下降的原因
    private static func analyzeProductivityDecrease(context: RootCauseContext) -> [Cause] {
        var causes: [Cause] = []
        
        // 原因1: 临近考试，时间转移到备考
        if !context.upcomingExams.isEmpty {
            let urgentExams = context.upcomingExams.filter { $0.daysRemaining() <= 7 }
            if !urgentExams.isEmpty {
                causes.append(Cause(
                    category: .externalEvent,
                    description: "临近考试，学习时间转移到备考复习",
                    evidence: "\(urgentExams.count)场考试即将开始",
                    confidence: 0.8
                ))
            }
        }
        
        // 原因2: 日程安排密集
        if context.weeklyEvents.count > Int(Double(context.avgWeeklyEvents) * 1.5) {
            causes.append(Cause(
                category: .timeConflict,
                description: "本周活动安排密集，挤压学习时间",
                evidence: "活动数量\(context.weeklyEvents.count)个，超出平均值\(Int((Double(context.weeklyEvents.count) / Double(context.avgWeeklyEvents) - 1) * 100))%",
                confidence: 0.7
            ))
        }
        
        // 原因3: 专注度下降
        if context.avgFocusScore < 60 {
            causes.append(Cause(
                category: .focusIssue,
                description: "平均专注度下降至\(Int(context.avgFocusScore))分",
                evidence: "频繁中断，环境干扰增加",
                confidence: 0.75
            ))
        }
        
        // 原因4: 目标缺失或不明确
        if context.activeGoals.isEmpty {
            causes.append(Cause(
                category: .motivationIssue,
                description: "缺少明确的学习目标",
                evidence: "当前无活跃的学习目标",
                confidence: 0.6
            ))
        }
        
        return causes
    }
    
    /// 分析习惯中断的原因
    private static func analyzeHabitBreak(context: RootCauseContext) -> [Cause] {
        var causes: [Cause] = []
        
        // 周末中断
        if context.isWeekend {
            causes.append(Cause(
                category: .timingIssue,
                description: "周末作息改变导致习惯中断",
                evidence: "中断发生在周末",
                confidence: 0.7
            ))
        }
        
        // 难度过高
        if context.habitDifficulty > 0.7 {
            causes.append(Cause(
                category: .difficultyIssue,
                description: "习惯难度设置过高",
                evidence: "历史完成率低于30%",
                confidence: 0.8
            ))
        }
        
        return causes
    }
    
    /// 分析待办积压的原因
    private static func analyzeTodoBacklog(context: RootCauseContext) -> [Cause] {
        var causes: [Cause] = []
        
        // 优先级混乱
        if context.highPriorityRatio > 0.6 {
            causes.append(Cause(
                category: .priorityIssue,
                description: "高优先级任务过多，缺乏重点",
                evidence: "\(Int(context.highPriorityRatio * 100))%的任务都是高优先级",
                confidence: 0.75
            ))
        }
        
        // 预估时间不准
        if context.avgActualVsEstimated > 1.5 {
            causes.append(Cause(
                category: .estimationIssue,
                description: "任务时间预估不准确，实际耗时超出预期",
                evidence: "实际耗时是预估的\(String(format: "%.1f", context.avgActualVsEstimated))倍",
                confidence: 0.8
            ))
        }
        
        return causes
    }
    
    /// 分析过度工作的原因
    private static func analyzeOverwork(context: RootCauseContext) -> [Cause] {
        var causes: [Cause] = []
        
        // 考试压力
        if context.upcomingExams.count >= 3 {
            causes.append(Cause(
                category: .externalPressure,
                description: "多场考试临近，备考压力大",
                evidence: "\(context.upcomingExams.count)场考试即将开始",
                confidence: 0.85
            ))
        }
        
        // 完美主义倾向
        if context.avgPomodoroLength > 40 {
            causes.append(Cause(
                category: .behavioralPattern,
                description: "单次学习时间过长，缺少必要休息",
                evidence: "平均番茄钟时长\(context.avgPomodoroLength)分钟",
                confidence: 0.7
            ))
        }
        
        return causes
    }
    
    // MARK: - 建议生成
    
    private static func generateRecommendation(for causes: [Cause]) -> String {
        guard let topCause = causes.first else {
            return "建议持续观察数据变化"
        }
        
        switch topCause.category {
        case .externalEvent:
            return "合理安排备考时间，考试后恢复正常节奏"
        case .timeConflict:
            return "优化时间分配，减少非必要活动"
        case .focusIssue:
            return "改善学习环境，开启免打扰模式"
        case .motivationIssue:
            return "设定明确的学习目标和里程碑"
        case .timingIssue:
            return "调整习惯提醒时间，适应作息变化"
        case .difficultyIssue:
            return "降低习惯难度，从小目标开始"
        case .priorityIssue:
            return "重新评估任务优先级，聚焦最重要的3件事"
        case .estimationIssue:
            return "使用番茄钟技术，提高时间预估准确性"
        case .externalPressure:
            return "合理分配学习压力，注意劳逸结合"
        case .behavioralPattern:
            return "遵循番茄工作法，25分钟工作+5分钟休息"
        }
    }
}

// MARK: - 数据结构

struct RootCause {
    let anomaly: Anomaly
    let causes: [Cause]
    let overallConfidence: Double
    let recommendation: String
    
    var primaryCause: Cause? {
        return causes.first
    }
}

struct Cause {
    let category: CauseCategory
    let description: String
    let evidence: String
    let confidence: Double // 0-1
    
    enum CauseCategory {
        case externalEvent      // 外部事件（考试、活动）
        case timeConflict       // 时间冲突
        case focusIssue         // 专注问题
        case motivationIssue    // 动力问题
        case timingIssue        // 时机问题
        case difficultyIssue    // 难度问题
        case priorityIssue      // 优先级问题
        case estimationIssue    // 预估问题
        case externalPressure   // 外部压力
        case behavioralPattern  // 行为模式
    }
}

struct RootCauseContext {
    let upcomingExams: [Exam]
    let weeklyEvents: [CalendarEvent]
    let avgWeeklyEvents: Int
    let avgFocusScore: Double
    let activeGoals: [Goal]
    let isWeekend: Bool
    let habitDifficulty: Double
    let highPriorityRatio: Double
    let avgActualVsEstimated: Double
    let avgPomodoroLength: Int
}

