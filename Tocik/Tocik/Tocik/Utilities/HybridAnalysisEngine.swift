//
//  HybridAnalysisEngine.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v4.0 - 混合分析引擎（本地规则 + 云端AI）
//

import Foundation
import SwiftData

@MainActor
class HybridAnalysisEngine {
    
    // MARK: - 分析触发条件
    
    /// 判断是否需要触发AI深度分析
    static func shouldTriggerAIAnalysis(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        userProfile: UserProfile?
    ) -> (shouldTrigger: Bool, reason: String?) {
        
        // 条件1: 距离上次AI分析超过3天
        if let lastAnalysis = userProfile?.lastAIAnalysisDate {
            let daysSinceLastAnalysis = Calendar.current.dateComponents([.day], from: lastAnalysis, to: Date()).day ?? 0
            if daysSinceLastAnalysis < 3 {
                return (false, nil)
            }
        }
        
        // 条件2: 本地检测到异常
        let anomalies = AnomalyDetector.detectAnomalies(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits
        )
        if !anomalies.isEmpty {
            return (true, "检测到\(anomalies.count)个异常，需要AI深度分析")
        }
        
        // 条件3: 数据量达到阈值
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentSessions = pomodoroSessions.filter { $0.startTime >= weekAgo }
        if recentSessions.count >= 10 {
            return (true, "本周数据充足，可进行全面分析")
        }
        
        return (false, nil)
    }
    
    // MARK: - 完整分析流程
    
    /// 执行混合分析（本地 + AI）- v5.0 增强版
    static func performHybridAnalysis(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        wrongQuestions: [WrongQuestion],
        flashCards: [FlashCard],
        goals: [Goal],
        subjects: [Subject],
        exams: [Exam],
        notes: [Note],
        reviewPlans: [ReviewPlan],
        studyJournals: [StudyJournal],
        courses: [CourseItem],
        calendarEvents: [CalendarEvent],
        countdowns: [Countdown],
        achievements: [Achievement],
        readingBooks: [ReadingBook],
        inspirations: [Inspiration],
        qaSessions: [QASession],
        userProfile: UserProfile?,
        context: ModelContext
    ) async -> HybridAnalysisResult {
        
        var result = HybridAnalysisResult()
        
        // 步骤1: 本地快速分析（v5.0 增强版）
        result.localAnalysis = performLocalAnalysis(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits,
            wrongQuestions: wrongQuestions,
            flashCards: flashCards,
            subjects: subjects,
            exams: exams,
            notes: notes,
            reviewPlans: reviewPlans
        )
        
        // 步骤2: 生成数据摘要（v5.0 增强版）
        let digest = generateDataDigest(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits,
            subjects: subjects,
            exams: exams,
            notes: notes,
            reviewPlans: reviewPlans,
            studyJournals: studyJournals,
            courses: courses,
            calendarEvents: calendarEvents,
            countdowns: countdowns,
            achievements: achievements,
            readingBooks: readingBooks,
            inspirations: inspirations,
            qaSessions: qaSessions,
            userProfile: userProfile
        )
        
        // 步骤3: 发送给AI分析（带Token追踪）
        let (aiResponse, tokens) = await DeepSeekManager.shared.analyzeWithDigest(digest: digest, userProfile: userProfile)
        
        if let aiResponse = aiResponse {
            result.aiAnalysis = aiResponse
            result.aiAnalysisSuccess = true
            result.tokensUsed = tokens
            
            // 步骤4: 解析AI响应并生成建议
            let suggestions = parseAIResponseToSuggestions(
                aiResponse: aiResponse,
                localInsights: result.localAnalysis
            )
            
            // 步骤5: 存储建议到数据库
            for suggestion in suggestions {
                context.insert(suggestion)
            }
            result.generatedSuggestions = suggestions
            
            // 步骤6: 更新用户画像
            if let profile = userProfile {
                updateUserProfile(
                    profile: profile,
                    basedOn: digest,
                    aiInsights: aiResponse
                )
                profile.lastAIAnalysisDate = Date()
            }
        } else {
            result.aiAnalysisSuccess = false
            // AI失败时，使用本地规则生成基础建议
            result.generatedSuggestions = SuggestionEngine.generateSuggestions(
                pomodoroSessions: pomodoroSessions,
                todos: todos,
                habits: habits,
                wrongQuestions: wrongQuestions,
                goals: goals,
                context: context
            )
        }
        
        return result
    }
    
    // MARK: - 本地分析
    
    static func performLocalAnalysis(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        wrongQuestions: [WrongQuestion],
        flashCards: [FlashCard],
        subjects: [Subject],
        exams: [Exam],
        notes: [Note],
        reviewPlans: [ReviewPlan]
    ) -> LocalAnalysisResult {
        
        var result = LocalAnalysisResult()
        
        // 学习模式分析
        result.studyPattern = SmartAnalyzer.analyzeStudyPattern(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits
        )
        
        // 知识弱点分析
        result.weaknesses = SmartAnalyzer.identifyWeaknesses(
            wrongQuestions: wrongQuestions,
            flashCards: flashCards
        )
        
        // 异常检测
        result.anomalies = AnomalyDetector.detectAnomalies(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits
        )
        
        // 效率评估
        result.efficiency = SmartAnalyzer.calculateEfficiency(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            timeRange: .lastWeek
        )
        
        // v5.0: 新增分析（使用简单逻辑避免依赖复杂结构体）
        result.subjectInsights = generateSubjectInsights(subjects: subjects, sessions: pomodoroSessions)
        result.examInsights = generateExamInsights(exams: exams)
        result.noteInsights = generateNoteInsights(notes: notes)
        result.reviewInsights = generateReviewInsights(reviewPlans: reviewPlans)
        
        return result
    }
    
    // MARK: - v5.0 新增洞察生成
    
    private static func generateSubjectInsights(subjects: [Subject], sessions: [PomodoroSession]) -> String {
        if subjects.isEmpty { return "尚未创建科目" }
        
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        var insights: [String] = []
        
        for subject in subjects {
            let weekSessions = sessions.filter { 
                $0.subjectId == subject.id && $0.startTime >= weekAgo 
            }.count
            if weekSessions < 3 {
                insights.append("\(subject.name)本周学习时长不足")
            }
        }
        
        return insights.isEmpty ? "科目学习均衡" : insights.joined(separator: ", ")
    }
    
    private static func generateExamInsights(exams: [Exam]) -> String {
        let upcoming = exams.filter { !$0.isFinished && $0.daysRemaining() <= 14 }
        if upcoming.isEmpty { return "暂无临近考试" }
        
        let urgent = upcoming.filter { $0.daysRemaining() <= 7 }
        if !urgent.isEmpty {
            return "有\(urgent.count)场考试即将开始，建议加强复习"
        }
        return "有\(upcoming.count)场考试临近"
    }
    
    private static func generateNoteInsights(notes: [Note]) -> String {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentNotes = notes.filter { $0.createdDate >= weekAgo }
        
        if recentNotes.isEmpty {
            return "本周未记录笔记，建议保持学习记录"
        }
        return "本周记录了\(recentNotes.count)篇笔记"
    }
    
    private static func generateReviewInsights(reviewPlans: [ReviewPlan]) -> String {
        let active = reviewPlans.filter { $0.status == .active }
        if active.isEmpty { return "暂无活跃的复习计划" }
        
        let behind = active.filter { $0.progress() < 0.3 }
        if !behind.isEmpty {
            return "有\(behind.count)个复习计划进度落后"
        }
        return "复习计划执行良好"
    }
    
    // MARK: - 数据摘要生成
    
    static func generateDataDigest(
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        habits: [Habit],
        subjects: [Subject],
        exams: [Exam],
        notes: [Note],
        reviewPlans: [ReviewPlan],
        studyJournals: [StudyJournal],
        courses: [CourseItem],
        calendarEvents: [CalendarEvent],
        countdowns: [Countdown],
        achievements: [Achievement],
        readingBooks: [ReadingBook],
        inspirations: [Inspiration],
        qaSessions: [QASession],
        userProfile: UserProfile?
    ) -> DataDigest {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentSessions = pomodoroSessions.filter { $0.startTime >= weekAgo }
        
        // 番茄钟摘要
        let completedSessions = recentSessions.filter { $0.isCompleted }
        let avgFocusScore = completedSessions.isEmpty ? 0 : completedSessions.map { $0.focusScore }.reduce(0, +) / Double(completedSessions.count)
        let bestHours = Dictionary(grouping: completedSessions, by: { Calendar.current.component(.hour, from: $0.startTime) })
            .sorted { $0.value.count > $1.value.count }
            .prefix(3)
            .map { $0.key }
        
        let pomodoroDigest = PomodoroDigest(
            totalCount: recentSessions.count,
            completionRate: recentSessions.isEmpty ? 0 : Double(completedSessions.count) / Double(recentSessions.count),
            avgFocusScore: avgFocusScore,
            bestHours: Array(bestHours),
            totalInterruptions: completedSessions.map { $0.interruptionCount }.reduce(0, +)
        )
        
        // 待办摘要
        let recentTodos = todos.filter { $0.createdDate >= weekAgo }
        let completedTodos = recentTodos.filter { $0.isCompleted }
        let overdueTodos = recentTodos.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) < Date() }
        let highPriorityTodos = recentTodos.filter { !$0.isCompleted && ($0.priority == .high || $0.priority == .urgent) }
        
        let todoDigest = TodoDigest(
            totalCount: recentTodos.count,
            completedCount: completedTodos.count,
            completionRate: recentTodos.isEmpty ? 0 : Double(completedTodos.count) / Double(recentTodos.count),
            overdueCount: overdueTodos.count,
            highPriorityCount: highPriorityTodos.count,
            avgCompletionTime: completedTodos.isEmpty ? 0 : completedTodos.map { $0.actualCompletionTime }.reduce(0, +) / completedTodos.count
        )
        
        // 习惯摘要
        let activeHabits = habits.filter { !$0.records.isEmpty }
        let streaks = activeHabits.map { $0.getCurrentStreak() }
        let recentRecords = habits.flatMap { $0.records }.filter { $0.date >= weekAgo }
        let totalPossibleCheckIns = activeHabits.count * 7
        
        let habitDigest = HabitDigest(
            activeHabitsCount: activeHabits.count,
            avgStreak: streaks.isEmpty ? 0 : streaks.reduce(0, +) / streaks.count,
            maxStreak: streaks.max() ?? 0,
            checkInRate: totalPossibleCheckIns == 0 ? 0 : Double(recentRecords.count) / Double(totalPossibleCheckIns)
        )
        
        // 学习模式摘要
        let totalStudyHours = Double(completedSessions.count) * 0.5
        let efficiencyTrend = calculateEfficiencyTrend(sessions: pomodoroSessions)
        let primaryStudyTime = determinePrimaryStudyTime(sessions: completedSessions)
        let procrastinationLevel = calculateProcrastinationLevel(todos: todos)
        
        let patternDigest = PatternDigest(
            totalStudyHours: totalStudyHours,
            efficiencyTrend: efficiencyTrend,
            primaryStudyTime: primaryStudyTime,
            procrastinationLevel: procrastinationLevel
        )
        
        // 用户画像摘要
        let userProfileDigest: UserProfileDigest? = userProfile != nil ? UserProfileDigest(
            learningStyle: userProfile!.learningStyle.rawValue,
            bestHours: bestHours,
            acceptanceRate: userProfile!.acceptanceRate,
            preferredSessionLength: userProfile!.preferredSessionLength
        ) : nil
        
        // v5.0: 新增数据摘要
        let subjectSummary = generateSubjectSummary(subjects: subjects, sessions: pomodoroSessions)
        let examSummary = generateExamSummary(exams: exams)
        let noteSummary = generateNoteSummary(notes: notes)
        let reviewSummary = generateReviewSummary(reviewPlans: reviewPlans)
        let courseSummary = generateCourseSummary(courses: courses)
        let achievementSummary = generateAchievementSummary(achievements: achievements)
        
        return DataDigest(
            period: .week,
            startDate: weekAgo,
            endDate: Date(),
            pomodoroSummary: pomodoroDigest,
            todoSummary: todoDigest,
            habitSummary: habitDigest,
            patternSummary: patternDigest,
            userProfile: userProfileDigest,
            subjectSummary: subjectSummary,
            examSummary: examSummary,
            noteSummary: noteSummary,
            reviewSummary: reviewSummary,
            courseSummary: courseSummary,
            achievementSummary: achievementSummary
        )
    }
    
    // MARK: - v5.0 新增摘要生成函数
    
    private static func generateSubjectSummary(subjects: [Subject], sessions: [PomodoroSession]) -> String {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        var summary: [String] = []
        
        for subject in subjects.prefix(5) {
            let weekSessions = sessions.filter { $0.subjectId == subject.id && $0.startTime >= weekAgo }.count
            summary.append("\(subject.name): \(String(format: "%.1f", Double(weekSessions) * 0.5))h")
        }
        
        return summary.isEmpty ? "无科目数据" : summary.joined(separator: ", ")
    }
    
    private static func generateExamSummary(exams: [Exam]) -> String {
        let upcoming = exams.filter { !$0.isFinished }.sorted { $0.examDate < $1.examDate }
        if upcoming.isEmpty { return "无即将到来的考试" }
        
        let nextExams = upcoming.prefix(3).map { "\($0.subject)(\($0.daysRemaining())天)" }
        return nextExams.joined(separator: ", ")
    }
    
    private static func generateNoteSummary(notes: [Note]) -> String {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentNotes = notes.filter { $0.createdDate >= weekAgo }
        
        let byCategory = Dictionary(grouping: recentNotes, by: { $0.category })
        let topCategories = byCategory.sorted { $0.value.count > $1.value.count }.prefix(3)
        
        return "本周\(recentNotes.count)篇，主要分类：" + topCategories.map { "\($0.key)(\($0.value.count))" }.joined(separator: ", ")
    }
    
    private static func generateReviewSummary(reviewPlans: [ReviewPlan]) -> String {
        let active = reviewPlans.filter { $0.status == .active }
        if active.isEmpty { return "无活跃复习计划" }
        
        let avgProgress = Int(active.map { $0.progress() }.reduce(0, +) / Double(active.count) * 100)
        return "\(active.count)个计划，平均进度\(avgProgress)%"
    }
    
    private static func generateCourseSummary(courses: [CourseItem]) -> String {
        let today = Calendar.current.component(.weekday, from: Date())
        let todayCourses = courses.filter { $0.weekday == today }
        
        return "本周\(courses.count)门课，今日\(todayCourses.count)节"
    }
    
    private static func generateAchievementSummary(achievements: [Achievement]) -> String {
        let unlocked = achievements.filter { $0.isUnlocked }
        return "已解锁\(unlocked.count)/\(achievements.count)个成就"
    }
    
    // 添加扩展属性到DataDigest（需要在数据结构中定义这些字段）
    private static func enhanceDataDigest(_ digest: inout DataDigest, 
                                         journals: [StudyJournal],
                                         events: [CalendarEvent],
                                         countdowns: [Countdown],
                                         books: [ReadingBook],
                                         inspirations: [Inspiration],
                                         qaSessions: [QASession]) {
        // 这些数据会被包含在AI分析的上下文中
    }
    
    // MARK: - AI响应解析
    
    static func parseAIResponseToSuggestions(
        aiResponse: String,
        localInsights: LocalAnalysisResult
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []
        
        // 简单的文本解析逻辑
        let lines = aiResponse.split(separator: "\n")
        var suggestionTexts: [String] = []
        var currentSection = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("建议") || trimmed.contains("✨") {
                currentSection = "suggestions"
            } else if currentSection == "suggestions" && (trimmed.hasPrefix("-") || trimmed.hasPrefix("•") || trimmed.hasPrefix("1") || trimmed.hasPrefix("2")) {
                suggestionTexts.append(String(trimmed))
            }
        }
        
        // 转换为SmartSuggestion对象
        for (index, text) in suggestionTexts.prefix(5).enumerated() {
            var cleanText = text.replacingOccurrences(of: "^[\\-•\\d\\.\\)\\s]+", with: "", options: .regularExpression)
            // 去除 Markdown 格式符号
            cleanText = cleanText.replacingOccurrences(of: "**", with: "")
            cleanText = cleanText.replacingOccurrences(of: "__", with: "")
            cleanText = cleanText.replacingOccurrences(of: "*", with: "")
            cleanText = cleanText.replacingOccurrences(of: "_", with: "")
            cleanText = cleanText.replacingOccurrences(of: "##", with: "")
            cleanText = cleanText.replacingOccurrences(of: "#", with: "")
            cleanText = cleanText.replacingOccurrences(of: "- ", with: "")
            cleanText = cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanText.isEmpty {
                let suggestion = SmartSuggestion(
                    suggestionType: .efficiency,
                    title: "AI建议 \(index + 1)",
                    content: cleanText,
                    priority: index == 0 ? .high : .medium,
                    isAIGenerated: true,
                    aiConfidence: 0.8
                )
                suggestions.append(suggestion)
            }
        }
        
        return suggestions
    }
    
    // MARK: - 用户画像更新
    
    private static func updateUserProfile(
        profile: UserProfile,
        basedOn digest: DataDigest,
        aiInsights: String
    ) {
        // 更新最佳学习时间
        if !digest.pomodoroSummary.bestHours.isEmpty {
            let timePreferences = ["bestHours": digest.pomodoroSummary.bestHours]
            if let jsonData = try? JSONSerialization.data(withJSONObject: timePreferences),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                profile.timePreferencesData = jsonString
            }
        }
        
        // 自适应调整番茄钟时长
        if digest.pomodoroSummary.completionRate > 0.8 {
            profile.preferredSessionLength = min(profile.preferredSessionLength + 5, 50)
        } else if digest.pomodoroSummary.completionRate < 0.5 {
            profile.preferredSessionLength = max(profile.preferredSessionLength - 5, 15)
        }
        
        // 存储AI洞察摘要
        profile.aiInsightsData = String(aiInsights.prefix(500))
        profile.lastUpdatedDate = Date()
    }
    
    // MARK: - 辅助方法
    
    private static func calculateEfficiencyTrend(sessions: [PomodoroSession]) -> String {
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let lastWeek = sessions.filter { $0.startTime >= oneWeekAgo }.count
        let previousWeek = sessions.filter { $0.startTime >= twoWeeksAgo && $0.startTime < oneWeekAgo }.count
        
        if lastWeek > previousWeek { return "上升" }
        if lastWeek < previousWeek { return "下降" }
        return "稳定"
    }
    
    private static func determinePrimaryStudyTime(sessions: [PomodoroSession]) -> String {
        let hourGroups = Dictionary(grouping: sessions) { session in
            Calendar.current.component(.hour, from: session.startTime)
        }
        
        let morningCount = hourGroups.filter { $0.key >= 6 && $0.key < 12 }.values.flatMap { $0 }.count
        let afternoonCount = hourGroups.filter { $0.key >= 12 && $0.key < 18 }.values.flatMap { $0 }.count
        let eveningCount = hourGroups.filter { $0.key >= 18 && $0.key < 24 }.values.flatMap { $0 }.count
        
        let max = Swift.max(morningCount, afternoonCount, eveningCount)
        if max == morningCount { return "上午" }
        if max == afternoonCount { return "下午" }
        return "晚上"
    }
    
    private static func calculateProcrastinationLevel(todos: [TodoItem]) -> String {
        let overdueTodos = todos.filter { !$0.isCompleted && ($0.dueDate ?? Date.distantFuture) < Date() }
        let totalTodos = todos.filter { !$0.isCompleted }
        
        guard !totalTodos.isEmpty else { return "低" }
        
        let overdueRate = Double(overdueTodos.count) / Double(totalTodos.count)
        if overdueRate > 0.3 { return "高" }
        if overdueRate > 0.1 { return "中" }
        return "低"
    }
    
    // MARK: - 智能推荐生成
    
    /// 生成AI推荐行动（习惯、目标、学习计划）
    static func generateRecommendedActions(
        digest: DataDigest,
        userProfile: UserProfile?,
        context: ModelContext
    ) async -> [RecommendedAction] {
        
        // 步骤1: 生成包含用户偏好的prompt
        let prompt = generateRecommendationPrompt(
            digest: digest,
            userProfile: userProfile
        )
        
        // 步骤2: 调用AI生成推荐
        guard let aiResponse = await DeepSeekManager.shared.chat(userMessage: prompt) else {
            print("⚠️ AI推荐生成失败")
            return []
        }
        
        // 步骤3: 解析推荐
        let recommendations = parseRecommendationsFromAI(aiResponse: aiResponse)
        
        // 步骤4: 基于用户反馈历史过滤和排序
        guard let profile = userProfile else {
            return Array(recommendations.prefix(3))
        }
        
        let filteredRecommendations = RecommendationLearningEngine.filterAndRankRecommendations(
            recommendations: recommendations,
            userProfile: profile
        )
        
        // 步骤5: 只返回前2-3条高分推荐
        return Array(filteredRecommendations.prefix(3))
    }
    
    /// 生成推荐prompt（包含用户偏好）
    private static func generateRecommendationPrompt(
        digest: DataDigest,
        userProfile: UserProfile?
    ) -> String {
        var prompt = """
        基于以下用户学习数据，请推荐2-3个具体的学习习惯或目标：
        
        \(digest.generateAIPrompt())
        
        要求：
        1. 必须具体、可执行、可量化
        2. 符合用户当前水平和可用时间
        3. 每个推荐严格按以下JSON格式返回
        
        返回格式（纯JSON，不要包含其他文字）：
        {
          "recommendations": [
            {
              "type": "habit",
              "title": "早起学习30分钟",
              "description": "每天早上6:30-7:00进行英语学习",
              "reason": "您的数据显示早晨专注度最高",
              "frequency": "daily",
              "targetValue": 1,
              "priority": 8,
              "icon": "sunrise.fill",
              "color": "#FFD93D",
              "timeSlot": "早晨",
              "difficulty": "medium",
              "category": "学习"
            }
          ]
        }
        """
        
        // 添加用户偏好信息
        if let profile = userProfile,
           let preferencesData = profile.recommendationPreferencesData.data(using: .utf8),
           let preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) {
            
            let highWeightTypes = preferences.habitTypeWeights.filter { $0.value > 0.7 }.map { $0.key }
            let lowWeightTypes = preferences.habitTypeWeights.filter { $0.value < 0.3 }.map { $0.key }
            
            prompt += """
            
            
            ### 用户偏好提示
            ✅ 用户更喜欢：\(highWeightTypes.isEmpty ? "无明显偏好" : highWeightTypes.joined(separator: ", "))
            ❌ 用户不喜欢：\(lowWeightTypes.isEmpty ? "无明显排斥" : lowWeightTypes.joined(separator: ", "))
            
            请在生成推荐时：
            - 优先推荐用户喜欢的类型
            - 避免推荐用户多次拒绝的类型
            - 如果必须推荐不喜欢的类型，请提供特别充分的理由
            """
        }
        
        return prompt
    }
    
    /// 解析AI返回的推荐JSON
    private static func parseRecommendationsFromAI(aiResponse: String) -> [RecommendedAction] {
        var recommendations: [RecommendedAction] = []
        
        // 尝试提取JSON部分
        guard let jsonStart = aiResponse.range(of: "{"),
              let jsonEnd = aiResponse.range(of: "}", options: .backwards) else {
            print("⚠️ 无法在AI响应中找到JSON")
            return []
        }
        
        let jsonString = String(aiResponse[jsonStart.lowerBound...jsonEnd.upperBound])
        
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let recsArray = json["recommendations"] as? [[String: Any]] else {
            print("⚠️ 无法解析AI推荐JSON")
            return []
        }
        
        // 解析每个推荐
        for recDict in recsArray {
            guard let type = recDict["type"] as? String,
                  let title = recDict["title"] as? String,
                  let description = recDict["description"] as? String,
                  let reason = recDict["reason"] as? String else {
                continue
            }
            
            let recommendationType: RecommendedAction.RecommendationType
            switch type {
            case "habit": recommendationType = .habit
            case "goal": recommendationType = .goal
            case "studyPlan": recommendationType = .studyPlan
            default: continue
            }
            
            // 将配置重新编码为JSON字符串
            let configData = recDict.filter { $0.key != "type" && $0.key != "title" && $0.key != "description" && $0.key != "reason" && $0.key != "priority" }
            let configString = (try? JSONSerialization.data(withJSONObject: configData)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
            
            let priority = recDict["priority"] as? Int ?? 5
            
            let recommendation = RecommendedAction(
                recommendationType: recommendationType,
                title: title,
                actionDescription: description,
                reason: reason,
                configurationData: configString,
                priority: priority,
                aiConfidence: 0.8
            )
            
            recommendations.append(recommendation)
        }
        
        print("✅ 解析到 \(recommendations.count) 条AI推荐")
        return recommendations
    }
    
    /// 接受推荐并创建实体
    static func acceptRecommendedAction(
        recommendation: RecommendedAction,
        context: ModelContext
    ) -> Bool {
        guard let configData = recommendation.configurationData.data(using: .utf8),
              let config = try? JSONSerialization.jsonObject(with: configData) as? [String: Any] else {
            print("⚠️ 无法解析推荐配置")
            return false
        }
        
        switch recommendation.recommendationType {
        case .habit:
            return createHabitFromRecommendation(config: config, recommendation: recommendation, context: context)
        case .goal:
            return createGoalFromRecommendation(config: config, recommendation: recommendation, context: context)
        case .studyPlan:
            return createStudyPlanFromRecommendation(config: config, recommendation: recommendation, context: context)
        }
    }
    
    // MARK: - 实体创建方法
    
    private static func createHabitFromRecommendation(
        config: [String: Any],
        recommendation: RecommendedAction,
        context: ModelContext
    ) -> Bool {
        let frequency: Habit.Frequency = (config["frequency"] as? String == "daily") ? .daily : .weekly
        let targetValue = config["targetValue"] as? Int ?? 1
        let icon = config["icon"] as? String ?? "star.fill"
        let color = config["color"] as? String ?? "#4A90E2"
        
        let habit = Habit(
            name: recommendation.title,
            icon: icon,
            colorHex: color,
            frequency: frequency,
            targetCount: targetValue
        )
        
        context.insert(habit)
        print("✅ 创建习惯: \(recommendation.title)")
        return true
    }
    
    private static func createGoalFromRecommendation(
        config: [String: Any],
        recommendation: RecommendedAction,
        context: ModelContext
    ) -> Bool {
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        
        let goal = Goal(
            title: recommendation.title,
            goalDescription: recommendation.actionDescription,
            timeframe: .monthly,
            startDate: Date(),
            endDate: endDate
        )
        
        context.insert(goal)
        print("✅ 创建目标: \(recommendation.title)")
        return true
    }
    
    private static func createStudyPlanFromRecommendation(
        config: [String: Any],
        recommendation: RecommendedAction,
        context: ModelContext
    ) -> Bool {
        // 创建总目标
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: 4, to: Date())!
        let goal = Goal(
            title: recommendation.title,
            goalDescription: recommendation.actionDescription,
            timeframe: .monthly,
            startDate: Date(),
            endDate: endDate
        )
        context.insert(goal)
        
        print("✅ 创建学习计划: \(recommendation.title)")
        return true
    }
}

// MARK: - 结果结构

struct HybridAnalysisResult {
    var localAnalysis: LocalAnalysisResult = LocalAnalysisResult()
    var aiAnalysis: String?
    var aiAnalysisSuccess: Bool = false
    var generatedSuggestions: [SmartSuggestion] = []
    var tokensUsed: Int = 0 // v5.0: Token消耗统计
}

struct LocalAnalysisResult {
    var studyPattern: StudyPattern?
    var weaknesses: [KnowledgeWeakness] = []
    var anomalies: [Anomaly] = []
    var efficiency: Double = 0
    
    // v5.0: 新增洞察字段
    var subjectInsights: String = ""
    var examInsights: String = ""
    var noteInsights: String = ""
    var reviewInsights: String = ""
}

