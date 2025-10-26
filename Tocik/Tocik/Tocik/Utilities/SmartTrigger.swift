//
//  SmartTrigger.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 智能触发管理器（优化13 + 17）
//

import Foundation

/// 智能触发决策引擎 - 优化AI调用时机，降低成本
class SmartTrigger {
    
    enum TriggerDecision {
        case immediate      // 立即触发AI
        case scheduled      // 延迟触发
        case skip           // 跳过
        case localOnly      // 仅本地分析
    }
    
    enum AnalysisMode {
        case fullAI         // 完整AI分析
        case lightAI        // 轻量AI分析（压缩prompt）
        case localOnly      // 仅本地
        case cached         // 使用缓存
        case minimal        // 最小化
    }
    
    /// 优化13: 智能触发条件评估
    static func shouldTriggerAnalysis(
        context: AnalysisContext,
        userProfile: UserProfile?
    ) -> (decision: TriggerDecision, mode: AnalysisMode, reason: String) {
        var score = 0
        var reasons: [String] = []
        
        // 维度1: 数据变化显著性 (0-40分)
        if context.newDataSignificance > 0.8 {
            score += 40
            reasons.append("数据变化显著")
        } else if context.newDataSignificance > 0.5 {
            score += 20
            reasons.append("数据有更新")
        }
        
        // 维度2: 用户主动性 (0-30分)
        if context.userActivelySeeks {
            score += 30
            reasons.append("用户主动查看")
        }
        
        // 维度3: 关键事件 (0-50分)
        if context.hasUrgentExam {
            score += 50
            reasons.append("紧急考试临近")
        } else if context.hasCriticalDeadline {
            score += 30
            reasons.append("重要截止日期")
        }
        
        // 维度4: 异常严重程度 (0-40分)
        switch context.anomalyLevel {
        case .critical:
            score += 40
            reasons.append("检测到严重异常")
        case .high:
            score += 25
            reasons.append("发现问题")
        case .medium:
            score += 10
        case .none:
            break
        }
        
        // 维度5: 时间间隔控制 (成本控制)
        let hoursSinceLastCall = context.hoursSinceLastAICall
        if hoursSinceLastCall < 6 {
            score -= 40
            reasons.append("避免频繁调用")
        } else if hoursSinceLastCall < 24 {
            score -= 20
        }
        
        // 维度6: Token预算 (成本控制)
        if let profile = userProfile {
            let remainingBudget = 10000 - profile.lastMonthTokensUsed // 假设月度预算10K
            if remainingBudget < 500 {
                score -= 50
                reasons.append("Token预算不足")
            }
        }
        
        // 决策逻辑
        let decision: TriggerDecision
        let mode: AnalysisMode
        
        if score >= 80 {
            decision = .immediate
            mode = .fullAI
        } else if score >= 50 {
            decision = .immediate
            mode = .lightAI // 使用压缩版prompt
        } else if score >= 30 {
            decision = .scheduled
            mode = .lightAI
        } else if score >= 10 {
            decision = .skip
            mode = .localOnly
        } else {
            decision = .skip
            mode = .cached
        }
        
        let reason = reasons.joined(separator: "，")
        return (decision, mode, reason.isEmpty ? "常规检查" : reason)
    }
    
    /// 优化17: 降级策略选择
    static func selectAnalysisMode(
        systemContext: SystemContext,
        userProfile: UserProfile?
    ) -> (mode: AnalysisMode, reason: String) {
        // 1. 网络检查
        if !systemContext.isNetworkAvailable {
            return (.localOnly, "离线模式")
        }
        
        // 2. API健康检查
        if systemContext.apiHealthScore < 0.3 {
            return (.cached, "API服务不稳定")
        }
        
        // 3. Token预算检查
        if let profile = userProfile {
            let remaining = 10000 - profile.lastMonthTokensUsed
            if remaining < 100 {
                return (.localOnly, "Token预算不足")
            } else if remaining < 500 {
                return (.lightAI, "节约模式")
            }
        }
        
        // 4. 缓存有效性检查
        if let lastAnalysis = systemContext.lastAnalysisDate,
           Date().timeIntervalSince(lastAnalysis) < 3600 { // 1小时内
            return (.cached, "使用最近分析结果")
        }
        
        // 5. 用户偏好
        if systemContext.userPrefersFastResponse {
            return (.localOnly, "用户偏好快速响应")
        }
        
        return (.fullAI, "执行完整分析")
    }
}

// MARK: - 上下文数据结构

struct AnalysisContext {
    let newDataSignificance: Double // 0-1，新数据的重要程度
    let userActivelySeeks: Bool      // 用户是否主动打开AI助手
    let hasUrgentExam: Bool          // 是否有紧急考试
    let hasCriticalDeadline: Bool    // 是否有关键截止日期
    let anomalyLevel: AnomalyLevel   // 异常级别
    let hoursSinceLastAICall: Double // 距离上次AI调用的小时数
    
    enum AnomalyLevel {
        case none, medium, high, critical
    }
}

struct SystemContext {
    let isNetworkAvailable: Bool
    let apiHealthScore: Double // 0-1
    let lastAnalysisDate: Date?
    let userPrefersFastResponse: Bool
}

