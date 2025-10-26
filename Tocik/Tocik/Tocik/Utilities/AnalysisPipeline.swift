//
//  AnalysisPipeline.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 模块化分析管道（优化15）
//

import Foundation
import SwiftData

/// 分析管道 - 将复杂分析流程拆分为独立可测试的阶段
@MainActor
class AnalysisPipeline {
    
    /// 执行完整分析管道
    static func execute(input: PipelineInput) async -> PipelineOutput {
        var state = PipelineState(input: input)
        
        print("🚀 分析管道启动...")
        
        // 阶段1: 数据收集与验证
        state = await DataCollectionStage.process(state)
        print("  ✓ 阶段1: 数据收集完成")
        
        // 阶段2: 缓存检查（优化1）
        state = await CacheCheckStage.process(state)
        if state.useCachedResult {
            print("  ⚡ 使用缓存结果，跳过计算")
            return state.output
        }
        
        // 阶段3: 本地快速分析
        state = await LocalAnalysisStage.process(state)
        print("  ✓ 阶段3: 本地分析完成")
        
        // 阶段4: 跨数据关联分析（优化6）
        state = await CrossDataStage.process(state)
        print("  ✓ 阶段4: 关联分析完成")
        
        // 阶段5: 异常根因分析（优化11）
        state = await RootCauseStage.process(state)
        print("  ✓ 阶段5: 根因分析完成")
        
        // 阶段6: 智能触发决策（优化13）
        state = await TriggerDecisionStage.process(state)
        print("  ✓ 阶段6: 触发决策完成")
        
        // 阶段7: AI分析（可选）
        if state.shouldCallAI {
            state = await AIAnalysisStage.process(state)
            print("  ✓ 阶段7: AI分析完成")
        } else {
            print("  ⊘ 阶段7: 跳过AI分析")
        }
        
        // 阶段8: 建议生成与排序（优化14 + 21）
        state = await SuggestionGenerationStage.process(state)
        print("  ✓ 阶段8: 建议生成完成")
        
        // 阶段9: 结果缓存
        state = await CacheUpdateStage.process(state)
        print("  ✓ 阶段9: 缓存更新完成")
        
        // 阶段10: 历史记录（优化10）
        state = await HistoryRecordStage.process(state)
        print("  ✓ 阶段10: 历史记录完成")
        
        print("🎉 分析管道完成！")
        
        return state.output
    }
}

// MARK: - 管道阶段

struct DataCollectionStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        // 数据验证和预处理
        newState.dataQuality = validateDataQuality(state.input)
        return newState
    }
    
    private static func validateDataQuality(_ input: PipelineInput) -> Double {
        // 检查数据完整性
        var score = 1.0
        if input.pomodoroSessions.isEmpty { score -= 0.2 }
        if input.todos.isEmpty { score -= 0.1 }
        if input.subjects.isEmpty { score -= 0.1 }
        return max(score, 0.0)
    }
}

struct CacheCheckStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 检查缓存
        if let cached = AnalysisCache.shared.getCachedStudyPattern() {
            newState.output.localResult.studyPattern = cached
            newState.useCachedResult = true
        }
        
        return newState
    }
}

struct LocalAnalysisStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 执行本地分析（使用优化后的引擎）
        newState.output.localResult = HybridAnalysisEngine.performLocalAnalysis(
            pomodoroSessions: state.input.pomodoroSessions,
            todos: state.input.todos,
            habits: state.input.habits,
            wrongQuestions: state.input.wrongQuestions,
            flashCards: state.input.flashCards,
            subjects: state.input.subjects,
            exams: state.input.exams,
            notes: state.input.notes,
            reviewPlans: state.input.reviewPlans
        )
        
        // 更新缓存
        if let pattern = newState.output.localResult.studyPattern {
            AnalysisCache.shared.cacheStudyPattern(pattern)
        }
        
        return newState
    }
}

struct CrossDataStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 跨数据关联分析
        newState.output.crossInsights = CrossDataInsights.findCorrelations(
            subjects: state.input.subjects,
            exams: state.input.exams,
            notes: state.input.notes,
            wrongQuestions: state.input.wrongQuestions,
            reviewPlans: state.input.reviewPlans,
            pomodoroSessions: state.input.pomodoroSessions,
            todos: state.input.todos,
            courses: state.input.courses,
            calendarEvents: state.input.calendarEvents
        )
        
        return newState
    }
}

struct RootCauseStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 为每个异常分析根本原因
        let context = buildRootCauseContext(from: state.input)
        
        newState.output.rootCauses = state.output.localResult.anomalies.map { anomaly in
            RootCauseAnalyzer.analyzeRootCause(anomaly, context: context)
        }
        
        return newState
    }
    
    private static func buildRootCauseContext(from input: PipelineInput) -> RootCauseContext {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentSessions = input.pomodoroSessions.filter { $0.startTime >= weekAgo && $0.isCompleted }
        let avgFocus = recentSessions.isEmpty ? 0 : recentSessions.map { $0.focusScore }.reduce(0, +) / Double(recentSessions.count)
        
        return RootCauseContext(
            upcomingExams: input.exams.filter { !$0.isFinished },
            weeklyEvents: input.calendarEvents,
            avgWeeklyEvents: 5,
            avgFocusScore: avgFocus,
            activeGoals: input.goals.filter { !$0.isArchived },
            isWeekend: Calendar.current.isDateInWeekend(Date()),
            habitDifficulty: 0.5,
            highPriorityRatio: 0.3,
            avgActualVsEstimated: 1.0,
            avgPomodoroLength: 25
        )
    }
}

struct TriggerDecisionStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 构建分析上下文
        let analysisContext = buildAnalysisContext(from: state)
        
        // 智能触发决策
        let (decision, mode, reason) = SmartTrigger.shouldTriggerAnalysis(
            context: analysisContext,
            userProfile: state.input.userProfile
        )
        
        newState.shouldCallAI = (decision == .immediate)
        newState.analysisMode = mode
        newState.triggerReason = reason
        
        return newState
    }
    
    private static func buildAnalysisContext(from state: PipelineState) -> AnalysisContext {
        // 计算数据重要性
        let significance = calculateDataSignificance(state)
        
        return AnalysisContext(
            newDataSignificance: significance,
            userActivelySeeks: state.input.userInitiated,
            hasUrgentExam: state.input.exams.contains(where: { !$0.isFinished && $0.daysRemaining() <= 3 }),
            hasCriticalDeadline: state.input.todos.contains(where: { ($0.dueDate ?? Date.distantFuture).timeIntervalSinceNow < 86400 }),
            anomalyLevel: state.output.localResult.anomalies.isEmpty ? .none : .high,
            hoursSinceLastAICall: state.input.hoursSinceLastAI
        )
    }
    
    private static func calculateDataSignificance(_ state: PipelineState) -> Double {
        // 简化计算
        let hasNewData = !state.input.pomodoroSessions.isEmpty
        return hasNewData ? 0.7 : 0.3
    }
}

struct AIAnalysisStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        // 生成优化后的摘要（优化8）
        let digest = HybridAnalysisEngine.generateDataDigest(
            pomodoroSessions: state.input.pomodoroSessions,
            todos: state.input.todos,
            habits: state.input.habits,
            subjects: state.input.subjects,
            exams: state.input.exams,
            notes: state.input.notes,
            reviewPlans: state.input.reviewPlans,
            studyJournals: state.input.studyJournals,
            courses: state.input.courses,
            calendarEvents: state.input.calendarEvents,
            countdowns: state.input.countdowns,
            achievements: state.input.achievements,
            readingBooks: state.input.readingBooks,
            inspirations: state.input.inspirations,
            qaSessions: state.input.qaSessions,
            userProfile: state.input.userProfile
        )
        
        // 增强prompt（优化10: 历史）
        let enhancedPrompt = AnalysisHistory.shared.enhancePromptWithHistory(baseDigest: digest)
        
        // 调用AI（使用弹性客户端，优化18）
        let (response, tokens) = await callAIWithResilience(prompt: enhancedPrompt)
        
        newState.output.aiResponse = response
        newState.output.tokensUsed = tokens
        
        return newState
    }
    
    private static func callAIWithResilience(prompt: String) async -> (String?, Int) {
        do {
            let result = try await ResilientAPIClient.shared.callWithTimeout(timeout: 30) {
                await DeepSeekManager.shared.chatWithTokenTracking(userMessage: prompt)
            }
            return result
        } catch {
            print("⚠️ AI调用失败: \(error.localizedDescription)")
            return (nil, 0)
        }
    }
}

struct SuggestionGenerationStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        var newState = state
        
        var allSuggestions: [SmartSuggestion] = []
        
        // 从跨数据洞察生成建议（使用模板，优化21）
        let templateSuggestions = SuggestionTemplateLibrary.shared.generateBatch(
            insights: state.output.crossInsights
        )
        allSuggestions.append(contentsOf: templateSuggestions)
        
        // 从AI响应解析建议
        if let aiResponse = state.output.aiResponse {
            let aiSuggestions = HybridAnalysisEngine.parseAIResponseToSuggestions(
                aiResponse: aiResponse,
                localInsights: state.output.localResult
            )
            allSuggestions.append(contentsOf: aiSuggestions)
        }
        
        // 过滤建议（基于学习到的偏好，优化4）
        let filtered = FeedbackLearningLoop.shared.filterSuggestions(allSuggestions)
        
        // 智能排序（优化14）
        let rankingContext = RankingContext(
            upcomingDeadlines: state.input.exams.map { $0.examDate },
            currentSchedule: [],
            historicalAcceptance: [:],
            recentSuggestions: []
        )
        
        newState.output.suggestions = SuggestionRanker.rank(
            suggestions: filtered,
            context: rankingContext
        )
        
        return newState
    }
}

struct CacheUpdateStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        // 更新各类缓存
        AnalysisCache.shared.cacheWeaknesses(state.output.localResult.weaknesses)
        AnalysisCache.shared.cacheAnomalies(state.output.localResult.anomalies)
        
        AnalysisCache.shared.cacheEfficiency(state.output.localResult.efficiency)
        
        return state
    }
}

struct HistoryRecordStage {
    static func process(_ state: PipelineState) async -> PipelineState {
        // 记录到历史
        AnalysisHistory.shared.recordInsight(
            suggestions: state.output.suggestions,
            analysisResult: state.output.localResult,
            aiResponse: state.output.aiResponse
        )
        
        return state
    }
}

// MARK: - 管道数据结构

struct PipelineInput {
    let pomodoroSessions: [PomodoroSession]
    let todos: [TodoItem]
    let habits: [Habit]
    let wrongQuestions: [WrongQuestion]
    let flashCards: [FlashCard]
    let goals: [Goal]
    let subjects: [Subject]
    let exams: [Exam]
    let notes: [Note]
    let reviewPlans: [ReviewPlan]
    let studyJournals: [StudyJournal]
    let courses: [CourseItem]
    let calendarEvents: [CalendarEvent]
    let countdowns: [Countdown]
    let achievements: [Achievement]
    let readingBooks: [ReadingBook]
    let inspirations: [Inspiration]
    let qaSessions: [QASession]
    let userProfile: UserProfile?
    let userInitiated: Bool
    let hoursSinceLastAI: Double
}

struct PipelineState {
    let input: PipelineInput
    var output: PipelineOutput
    var dataQuality: Double
    var useCachedResult: Bool
    var shouldCallAI: Bool
    var analysisMode: SmartTrigger.AnalysisMode
    var triggerReason: String
    
    init(input: PipelineInput) {
        self.input = input
        self.output = PipelineOutput()
        self.dataQuality = 1.0
        self.useCachedResult = false
        self.shouldCallAI = false
        self.analysisMode = .localOnly
        self.triggerReason = ""
    }
}

struct PipelineOutput {
    var localResult: LocalAnalysisResult = LocalAnalysisResult()
    var crossInsights: [CrossDataInsight] = []
    var rootCauses: [RootCause] = []
    var suggestions: [SmartSuggestion] = []
    var aiResponse: String?
    var tokensUsed: Int = 0
}

