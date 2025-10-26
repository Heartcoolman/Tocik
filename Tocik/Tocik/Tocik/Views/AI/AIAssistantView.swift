//
//  AIAssistantView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - AI助手（重构版：现代卡片布局 + 标签页）
//

import SwiftUI
import SwiftData

struct AIAssistantView: View {
    @Query private var suggestions: [SmartSuggestion]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var goals: [Goal]
    @Query private var flashCards: [FlashCard]
    @Query private var userProfiles: [UserProfile]
    @Query private var allRecommendations: [RecommendedAction]
    
    // v5.0: 新增数据源
    @Query private var subjects: [Subject]
    @Query private var exams: [Exam]
    @Query private var notes: [Note]
    @Query private var reviewPlans: [ReviewPlan]
    @Query private var studyJournals: [StudyJournal]
    @Query private var courses: [CourseItem]
    @Query private var calendarEvents: [CalendarEvent]
    @Query private var countdowns: [Countdown]
    @Query private var achievements: [Achievement]
    @Query private var readingBooks: [ReadingBook]
    @Query private var inspirations: [Inspiration]
    @Query private var qaSessions: [QASession]
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 状态管理
    @State private var showAnalyzing = false
    @State private var studyPattern: StudyPattern?
    @State private var weaknesses: [KnowledgeWeakness] = []
    @State private var anomalies: [Anomaly] = []
    @State private var crossInsights: [CrossDataInsight] = []
    @State private var rootCauses: [RootCause] = []
    @State private var analysisProgress: AnalysisProgress = .idle
    @State private var streamingText: String = ""
    @State private var useStreamingMode: Bool = true
    
    // 标签页状态
    @State private var selectedTab: AnalysisTab = .realtime
    
    enum AnalysisTab: String, CaseIterable {
        case realtime = "实时分析"
        case insights = "数据洞察"
        case suggestions = "建议中心"
        case history = "分析历史"
        
        var icon: String {
            switch self {
            case .realtime: return "brain.head.profile"
            case .insights: return "chart.xyaxis.line"
            case .suggestions: return "lightbulb.fill"
            case .history: return "clock.arrow.circlepath"
            }
        }
    }
    
    enum AnalysisProgress {
        case idle
        case localAnalyzing
        case aiAnalyzing
        case completed
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部概览区域
                if horizontalSizeClass == .regular {
                    // iPad: 显示完整概览
                    overviewSection
                        .padding()
                }
                
                // 标签页切换器
                tabPicker
                
                // 标签页内容
                TabView(selection: $selectedTab) {
                    RealtimeAnalysisTab(
                        analysisProgress: analysisProgress,
                        streamingText: streamingText,
                        triggerConditions: triggerConditions,
                        onAnalyze: performHybridAnalysis
                    )
                    .tag(AnalysisTab.realtime)
                    
                    DataInsightsTab(
                        studyPattern: studyPattern,
                        weaknesses: weaknesses,
                        anomalies: anomalies,
                        crossInsights: crossInsights,
                        pomodoroSessions: pomodoroSessions
                    )
                    .tag(AnalysisTab.insights)
                    
                    SuggestionCenterTab(
                        suggestions: unreadSuggestions,
                        recommendations: pendingRecommendations,
                        onSuggestionFeedback: handleSuggestionFeedback,
                        onAcceptRecommendation: acceptRecommendation,
                        onRejectRecommendation: rejectRecommendation
                    )
                    .tag(AnalysisTab.suggestions)
                    
                    AnalysisHistoryTab()
                        .tag(AnalysisTab.history)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("AI 助手")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { useStreamingMode.toggle() }) {
                            Label(
                                useStreamingMode ? "使用结构化输出" : "使用流式输出",
                                systemImage: useStreamingMode ? "list.bullet" : "text.bubble"
                            )
                        }
                        
                        Divider()
                        
                        Button(action: exportReport) {
                            Label("导出分析报告", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .onAppear {
                checkAndTriggerAnalysisIfNeeded()
            }
        }
    }
    
    // MARK: - 顶部概览区域
    
    @ViewBuilder
    private var overviewSection: some View {
        VStack(spacing: Theme.spacing.large) {
            // 环形进度仪表盘
            AIAnalysisProgressRing(
                progress: analysisProgressValue,
                dataReadiness: dataReadinessValue,
                acceptanceRate: userProfiles.first?.acceptanceRate ?? 0
            )
            
            // 数据摘要卡片网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                ModernOverviewCard(
                    title: "学习效率",
                    value: studyPattern != nil ? String(format: "%.0f分", studyPattern!.averageFocusScore) : "-",
                    icon: "brain",
                    gradient: Theme.statsGradient
                )
                
                ModernOverviewCard(
                    title: "完成率",
                    value: studyPattern != nil ? String(format: "%.0f%%", studyPattern!.taskCompletionRate * 100) : "-",
                    icon: "checkmark.circle",
                    gradient: Theme.habitGradient
                )
                
                ModernOverviewCard(
                    title: "知识弱点",
                    value: "\(weaknesses.count)",
                    icon: "exclamationmark.triangle",
                    gradient: Theme.todoGradient
                )
                
                ModernOverviewCard(
                    title: "异常检测",
                    value: "\(anomalies.count)",
                    icon: "bolt.fill",
                    gradient: Theme.pomodoroGradient
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }
    
    // MARK: - 标签页选择器
    
    @ViewBuilder
    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    TabPickerButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        badgeCount: tabBadgeCount(for: tab),
                        action: { 
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 辅助计算属性
    
    private var analysisProgressValue: Double {
        switch analysisProgress {
        case .idle: return 0
        case .localAnalyzing: return 0.5
        case .aiAnalyzing: return 0.75
        case .completed: return 1.0
        }
    }
    
    private var dataReadinessValue: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let weekPomodoros = pomodoroSessions.filter { $0.startTime >= weekAgo }.count
        return min(Double(weekPomodoros) / 10.0, 1.0)
    }
    
    private var unreadSuggestions: [SmartSuggestion] {
        suggestions.filter { !($0.expiryDate ?? Date.distantFuture < Date()) }
    }
    
    private var pendingRecommendations: [RecommendedAction] {
        allRecommendations.filter { $0.status == .pending }
    }
    
    private var triggerConditions: [(title: String, isMet: Bool, description: String)] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let weekPomodoros = pomodoroSessions.filter { $0.startTime >= weekAgo }.count
        
        var conditions: [(String, Bool, String)] = []
        
        // 条件1: 时间间隔
        if let lastAnalysis = userProfiles.first?.lastAIAnalysisDate {
            let days = Calendar.current.dateComponents([.day], from: lastAnalysis, to: Date()).day ?? 0
            conditions.append((
                "距离上次分析超过3天",
                days >= 3,
                "上次分析：\(days)天前"
            ))
        } else {
            conditions.append((
                "距离上次分析超过3天",
                true,
                "首次使用"
            ))
        }
        
        // 条件2: 数据量
        conditions.append((
            "本周数据量充足",
            weekPomodoros >= 10,
            "本周已完成 \(weekPomodoros) 个番茄钟（需要≥10）"
        ))
        
        // 条件3: 异常检测
        let hasAnomalies = !anomalies.isEmpty
        conditions.append((
            "检测到学习异常",
            hasAnomalies,
            hasAnomalies ? "发现 \(anomalies.count) 个异常" : "暂未检测到异常"
        ))
        
        return conditions
    }
    
    private func tabBadgeCount(for tab: AnalysisTab) -> Int {
        switch tab {
        case .realtime: return 0
        case .insights: return crossInsights.count + anomalies.count
        case .suggestions: return unreadSuggestions.filter { $0.userFeedback == nil }.count
        case .history: return 0
        }
    }
    
    // MARK: - 分析功能
    
    private func checkAndTriggerAnalysisIfNeeded() {
        let (shouldTrigger, reason) = HybridAnalysisEngine.shouldTriggerAIAnalysis(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits,
            userProfile: userProfiles.first
        )
        
        if shouldTrigger {
            print("🤖 智能触发AI分析: \(reason ?? "")")
            performHybridAnalysis()
        } else {
            print("ℹ️ 条件未满足，不触发AI分析")
            performLocalQuickAnalysis()
        }
    }
    
    private func performLocalQuickAnalysis() {
        let pomodoroSessionsData = pomodoroSessions
        let todosData = todos
        let habitsData = habits
        let wrongQuestionsData = wrongQuestions
        let flashCardsData = flashCards
        let subjectsData = subjects
        let examsData = exams
        let notesData = notes
        let reviewPlansData = reviewPlans
        let coursesData = courses
        let calendarEventsData = calendarEvents
        
        Task.detached(priority: .userInitiated) { [self] in
            await MainActor.run {
                self.analysisProgress = .localAnalyzing
            }
            
            let pattern = await SmartAnalyzer.analyzeStudyPattern(
                pomodoroSessions: pomodoroSessionsData,
                todos: todosData,
                habits: habitsData
            )
            let weaknesses = await SmartAnalyzer.identifyWeaknesses(
                wrongQuestions: wrongQuestionsData,
                flashCards: flashCardsData
            )
            let anomalies = await AnomalyDetector.detectAnomalies(
                pomodoroSessions: pomodoroSessionsData,
                todos: todosData,
                habits: habitsData
            )
            
            let insights = await CrossDataInsights.findCorrelations(
                subjects: subjectsData,
                exams: examsData,
                notes: notesData,
                wrongQuestions: wrongQuestionsData,
                reviewPlans: reviewPlansData,
                pomodoroSessions: pomodoroSessionsData,
                todos: todosData,
                courses: coursesData,
                calendarEvents: calendarEventsData
            )
            
            await MainActor.run {
                self.studyPattern = pattern
                self.weaknesses = weaknesses
                self.anomalies = anomalies
                self.crossInsights = insights
                self.analysisProgress = .completed
            }
        }
    }
    
    private func performHybridAnalysis() {
        Task { [self] in
            await self.performProgressiveAnalysis()
        }
    }
    
    private func performProgressiveAnalysis() async {
        analysisProgress = .localAnalyzing
        
        await MainActor.run {
            self.studyPattern = SmartAnalyzer.analyzeStudyPattern(
                pomodoroSessions: pomodoroSessions,
                todos: todos,
                habits: habits
            )
            self.weaknesses = SmartAnalyzer.identifyWeaknesses(
                wrongQuestions: wrongQuestions,
                flashCards: flashCards
            )
            self.anomalies = AnomalyDetector.detectAnomalies(
                pomodoroSessions: pomodoroSessions,
                todos: todos,
                habits: habits
            )
            
            self.crossInsights = CrossDataInsights.findCorrelations(
                subjects: subjects,
                exams: exams,
                notes: notes,
                wrongQuestions: wrongQuestions,
                reviewPlans: reviewPlans,
                pomodoroSessions: pomodoroSessions,
                todos: todos,
                courses: courses,
                calendarEvents: calendarEvents
            )
        }
        
        let hoursSince = userProfiles.first?.lastAIAnalysisDate.map { 
            Date().timeIntervalSince($0) / 3600 
        } ?? 999
        
        let analysisContext = AnalysisContext(
            newDataSignificance: 0.7,
            userActivelySeeks: true,
            hasUrgentExam: exams.contains(where: { !$0.isFinished && $0.daysRemaining() <= 3 }),
            hasCriticalDeadline: false,
            anomalyLevel: anomalies.isEmpty ? .none : .high,
            hoursSinceLastAICall: hoursSince
        )
        
        let (decision, mode, reason) = SmartTrigger.shouldTriggerAnalysis(
            context: analysisContext,
            userProfile: userProfiles.first
        )
        
        print("🤖 触发决策: \(decision), 模式: \(mode), 原因: \(reason)")
        
        if decision == .immediate || decision == .scheduled {
            await performAIAnalysis(mode: mode)
        } else {
            await MainActor.run {
                self.analysisProgress = .completed
                self.showAnalyzing = false
            }
        }
    }
    
    private func performAIAnalysis(mode: SmartTrigger.AnalysisMode) async {
        await MainActor.run {
            analysisProgress = .aiAnalyzing
            showAnalyzing = true
        }
        
        let digest = HybridAnalysisEngine.generateDataDigest(
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
            userProfile: userProfiles.first
        )
        
        let prompt: String
        switch mode {
        case .lightAI:
            prompt = TokenOptimizer.compressDigest(digest, mode: .smart)
        case .fullAI:
            prompt = AnalysisHistory.shared.enhancePromptWithHistory(baseDigest: digest)
        default:
            prompt = digest.generateAIPrompt()
        }
        
        let enhancedPrompt = FeedbackLearningLoop.shared.enhancePrompt(
            prompt,
            userProfile: userProfiles.first
        )
        
        if useStreamingMode {
            await performStreamingAnalysis(prompt: enhancedPrompt)
        } else {
            await performStructuredAnalysis(prompt: enhancedPrompt)
        }
    }
    
    private func performStreamingAnalysis(prompt: String) async {
        streamingText = ""
        
        let tokens = await DeepSeekManager.shared.chatWithStreaming(userMessage: prompt) { chunk in
            streamingText += chunk
        }
        
        AnalysisHistory.shared.recordInsight(
            suggestions: [],
            analysisResult: LocalAnalysisResult(
                studyPattern: studyPattern,
                weaknesses: weaknesses,
                anomalies: anomalies
            ),
            aiResponse: streamingText
        )
        
        await MainActor.run {
            self.showAnalyzing = false
            self.analysisProgress = .completed
            
            userProfiles.first?.lastAIAnalysisDate = Date()
            userProfiles.first?.recordTokenUsage(tokens: tokens, callType: .analysis)
            try? context.save()
            
            HapticManager.shared.success()
            print("✅ 流式AI分析完成 - 消耗 \(tokens) tokens")
        }
    }
    
    private func performStructuredAnalysis(prompt: String) async {
        let (response, tokens) = await DeepSeekManager.shared.chatWithStructuredOutput(userMessage: prompt)
        
        await MainActor.run {
            if let response = response {
                AnalysisHistory.shared.recordInsight(
                    suggestions: [],
                    analysisResult: LocalAnalysisResult(
                        studyPattern: studyPattern,
                        weaknesses: weaknesses,
                        anomalies: anomalies
                    ),
                    aiResponse: response.analysis
                )
                
                userProfiles.first?.lastAIAnalysisDate = Date()
                userProfiles.first?.recordTokenUsage(tokens: tokens, callType: .analysis)
                try? context.save()
                
                HapticManager.shared.success()
                print("✅ 结构化AI分析完成 - 消耗 \(tokens) tokens")
            } else {
                HapticManager.shared.warning()
                print("⚠️ AI分析失败，使用本地规则")
            }
            
            self.showAnalyzing = false
            self.analysisProgress = .completed
        }
    }
    
    // MARK: - 反馈处理
    
    private func handleSuggestionFeedback(_ suggestion: SmartSuggestion, _ feedback: SuggestionFeedback.FeedbackAction) {
        suggestion.userFeedback = feedback.rawValue
        suggestion.feedbackDate = Date()
        
        let feedbackRecord = SuggestionFeedback(
            suggestionId: suggestion.id,
            suggestionType: suggestion.suggestionType.rawValue,
            action: feedback
        )
        context.insert(feedbackRecord)
        
        FeedbackLearningLoop.shared.learn(from: feedbackRecord)
        
        if suggestion.isAIGenerated, let profile = userProfiles.first {
            profile.feedbackHistory.append(feedbackRecord)
            profile.totalSuggestionsReceived += 1
            
            if feedback == .helpful || feedback == .implemented {
                profile.totalSuggestionsAccepted += 1
                AnalysisHistory.shared.recordUserAction(action: "接受建议: \(suggestion.title)")
            } else if feedback == .notHelpful {
                profile.totalSuggestionsRejected += 1
            }
            profile.updateAcceptanceRate()
        }
        
        try? context.save()
        HapticManager.shared.light()
    }
    
    private func acceptRecommendation(_ recommendation: RecommendedAction) {
        let success = HybridAnalysisEngine.acceptRecommendedAction(
            recommendation: recommendation,
            context: context
        )
        
        if success {
            RecommendationLearningEngine.recordFeedback(
                recommendation: recommendation,
                feedback: .accepted,
                userProfile: userProfiles.first,
                context: context
            )
            
            recommendation.status = .accepted
            try? context.save()
            HapticManager.shared.success()
        }
    }
    
    private func rejectRecommendation(_ recommendation: RecommendedAction) {
        RecommendationLearningEngine.recordFeedback(
            recommendation: recommendation,
            feedback: .rejected,
            userProfile: userProfiles.first,
            context: context
        )
        
        recommendation.status = .rejected
        try? context.save()
        HapticManager.shared.warning()
    }
    
    private func exportReport() {
        // TODO: 实现导出报告功能
        print("导出分析报告")
        HapticManager.shared.light()
    }
}

// MARK: - 标签页选择按钮

struct TabPickerButton: View {
    let tab: AIAssistantView.AnalysisTab
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? Theme.primaryGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                    
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(tab.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? Theme.primaryColor : .secondary)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.primaryColor.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    AIAssistantView()
        .modelContainer(for: [
            SmartSuggestion.self,
            PomodoroSession.self,
            TodoItem.self,
            Habit.self,
            WrongQuestion.self,
            Goal.self,
            FlashCard.self,
            UserProfile.self,
            RecommendedAction.self
        ])
}
