//
//  DeveloperSettingsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  开发者设置 - 测试数据生成和调试工具
//

import SwiftUI
import SwiftData

struct DeveloperSettingsView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var flashCards: [FlashCard]
    @Query private var suggestions: [SmartSuggestion]
    @Query private var recommendations: [RecommendedAction]
    @Query private var userProfiles: [UserProfile]
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
    @Query private var goals: [Goal]
    @Environment(\.modelContext) private var context
    
    @State private var customCount = 10
    @State private var mockDataStartDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @State private var showingDangerAlert = false
    @State private var showPreferences = false
    
    var body: some View {
        NavigationStack {
            List {
                // 数据模拟器
                Section("数据模拟") {
                    Button("生成10个番茄钟记录") { generateMockPomodoros(10) }
                    Button("生成50个番茄钟记录") { generateMockPomodoros(50) }
                    Stepper("自定义数量: \(customCount)", value: $customCount, in: 1...100)
                    Button("生成自定义数量") { generateMockPomodoros(customCount) }
                    
                    Divider()
                    
                    Button("生成20个待办任务") { generateMockTodos(20) }
                    Button("生成已完成任务(15个)") { generateCompletedTodos(15) }
                    Button("生成过期任务(5个)") { generateOverdueTodos(5) }
                    
                    Divider()
                    
                    Button("生成30天习惯打卡") { generateHabitRecords(30) }
                    Button("生成中断习惯") { generateBrokenHabit() }
                    
                    Divider()
                    
                    Button("生成30道错题") { generateWrongQuestions(30) }
                    Button("生成100张闪卡") { generateFlashCards(100) }
                }
                
                // 时间操纵器
                Section("时间调整") {
                    Button("重置AI分析时间（触发分析）") {
                        if let profile = userProfiles.first {
                            profile.lastAIAnalysisDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
                            HapticManager.shared.success()
                        }
                    }
                    
                    DatePicker("模拟数据起始时间", selection: $mockDataStartDate, displayedComponents: [.date])
                }
                
                // AI测试工具
                Section("AI功能测试") {
                    Button("立即触发AI分析") {
                        Task { [self] in
                            await self.performHybridAnalysis()
                        }
                    }
                    
                    Button("生成AI推荐") {
                        Task { [self] in
                            await self.generateRecommendations()
                        }
                    }
                    
                    if let profile = userProfiles.first {
                        HStack {
                            Text("接受率")
                            Spacer()
                            Text(String(format: "%.1f%%", profile.acceptanceRate * 100))
                                .foregroundColor(.blue)
                        }
                        
                        Button("查看偏好权重") { showPreferences = true }
                    }
                }
                
                // 快捷场景
                Section("快捷场景") {
                    Button("新学期场景（5科目 + 基础数据）") {
                        createNewSemesterScenario()
                    }
                    
                    Button("备考场景（考试倒计时 + 复习计划）") {
                        createExamPrepScenario()
                    }
                    
                    Button("学霸场景（高完成率 + 长连续）") {
                        createTopStudentScenario()
                    }
                    
                    Button("拖延场景（低完成率 + 过期任务）") {
                        createProcrastinationScenario()
                    }
                }
                
                // 数据查看
                Section("数据统计") {
                    LabeledContent("番茄钟", value: "\(pomodoroSessions.count)")
                    LabeledContent("待办", value: "\(todos.count)")
                    LabeledContent("习惯", value: "\(habits.count)")
                    LabeledContent("错题", value: "\(wrongQuestions.count)")
                    LabeledContent("闪卡", value: "\(flashCards.count)")
                    LabeledContent("AI建议", value: "\(suggestions.count)")
                    LabeledContent("AI推荐", value: "\(recommendations.count)")
                    LabeledContent("科目", value: "\(subjects.count)")
                    LabeledContent("考试", value: "\(exams.count)")
                }
                
                // AI Token统计
                Section("AI Token统计") {
                    if let profile = userProfiles.first {
                        LabeledContent("总消耗Token", value: "\(profile.totalTokensUsed)")
                        LabeledContent("本月Token", value: "\(profile.lastMonthTokensUsed)")
                        LabeledContent("分析调用", value: "\(profile.totalAIAnalysisCalls)次")
                        LabeledContent("推荐调用", value: "\(profile.totalAIRecommendationCalls)次")
                        LabeledContent("建议接受率", value: String(format: "%.1f%%", profile.acceptanceRate * 100))
                        
                        if let resetDate = profile.monthResetDate {
                            LabeledContent("月度重置", value: resetDate.formatted(date: .abbreviated, time: .omitted))
                        }
                    } else {
                        Text("用户画像未初始化")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 危险操作
                Section("数据清理") {
                    Button("清空测试数据", role: .destructive) {
                        clearTestData()
                    }
                    
                    Button("重置用户画像", role: .destructive) {
                        resetUserProfile()
                    }
                    
                    Button("清空所有数据", role: .destructive) {
                        showingDangerAlert = true
                    }
                }
            }
            .navigationTitle("开发者设置")
            .alert("确定清空所有数据？", isPresented: $showingDangerAlert) {
                Button("取消", role: .cancel) { }
                Button("确定清空", role: .destructive) {
                    clearAllData()
                }
            }
            .sheet(isPresented: $showPreferences) {
                PreferencesDetailView()
            }
        }
    }
    
    // MARK: - 数据生成方法
    
    private func generateMockPomodoros(_ count: Int) {
        for _ in 0..<count {
            let daysAgo = Int.random(in: 0...30)
            let hoursAgo = Int.random(in: 0...23)
            let startTime = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            let adjustedStartTime = Calendar.current.date(bySettingHour: hoursAgo, minute: 0, second: 0, of: startTime)!
            
            let session = PomodoroSession(
                startTime: adjustedStartTime,
                endTime: Calendar.current.date(byAdding: .minute, value: 25, to: adjustedStartTime)!,
                sessionType: .work,
                isCompleted: true
            )
            session.focusScore = Double.random(in: 70...100)
            context.insert(session)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateMockTodos(_ count: Int) {
        let categories = ["学习", "作业", "复习", "备考"]
        for i in 0..<count {
            let todo = TodoItem(
                title: "任务 \(i + 1)",
                priority: TodoItem.Priority.allCases.randomElement()!,
                category: categories.randomElement()!
            )
            context.insert(todo)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateCompletedTodos(_ count: Int) {
        for i in 0..<count {
            let todo = TodoItem(title: "已完成任务 \(i + 1)", isCompleted: true)
            todo.completedDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...7), to: Date())
            context.insert(todo)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateOverdueTodos(_ count: Int) {
        for i in 0..<count {
            let todo = TodoItem(title: "过期任务 \(i + 1)")
            todo.dueDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...10), to: Date())
            context.insert(todo)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateHabitRecords(_ days: Int) {
        let habit = Habit(name: "测试习惯")
        for i in 0..<days {
            let record = HabitRecord(
                date: Calendar.current.date(byAdding: .day, value: -days + i, to: Date())!
            )
            habit.records.append(record)
        }
        context.insert(habit)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateBrokenHabit() {
        let habit = Habit(name: "中断习惯")
        // 添加7天前的记录
        for i in 0..<7 {
            let record = HabitRecord(
                date: Calendar.current.date(byAdding: .day, value: -14 + i, to: Date())!
            )
            habit.records.append(record)
        }
        context.insert(habit)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateWrongQuestions(_ count: Int) {
        let subjects = ["数学", "英语", "物理", "化学"]
        for i in 0..<count {
            let question = WrongQuestion(
                subject: subjects.randomElement()!,
                analysis: "测试错题 \(i + 1) 的解析",
                note: "这是一道测试题目"
            )
            context.insert(question)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func generateFlashCards(_ count: Int) {
        for i in 0..<count {
            let card = FlashCard(
                question: "问题 \(i + 1)",
                answer: "答案 \(i + 1)"
            )
            context.insert(card)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    // 快捷场景
    private func createNewSemesterScenario() {
        let subjectNames = ["数学", "英语", "物理", "化学", "生物"]
        for name in subjectNames {
            let subject = Subject(name: name)
            context.insert(subject)
        }
        generateMockPomodoros(30)
        generateMockTodos(15)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func createExamPrepScenario() {
        let exam = Exam(examName: "期末考试", subject: "数学", examDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
        context.insert(exam)
        generateMockPomodoros(20)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func createTopStudentScenario() {
        generateMockPomodoros(80)
        generateCompletedTodos(50)
        generateHabitRecords(30)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func createProcrastinationScenario() {
        generateMockPomodoros(10)
        generateOverdueTodos(20)
        generateBrokenHabit()
        try? context.save()
        HapticManager.shared.success()
    }
    
    // AI测试
    private func performHybridAnalysis() async {
        let _ = await HybridAnalysisEngine.performHybridAnalysis(
            pomodoroSessions: pomodoroSessions,
            todos: todos,
            habits: habits,
            wrongQuestions: wrongQuestions,
            flashCards: flashCards,
            goals: goals,
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
            userProfile: userProfiles.first,
            context: context
        )
        await MainActor.run {
            HapticManager.shared.success()
        }
    }
    
    private func generateRecommendations() async {
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
        
        let _ = await HybridAnalysisEngine.generateRecommendedActions(
            digest: digest,
            userProfile: userProfiles.first,
            context: context
        )
        
        await MainActor.run {
            HapticManager.shared.success()
        }
    }
    
    // 数据清理
    private func clearTestData() {
        // 清空非核心数据
        for session in pomodoroSessions {
            context.delete(session)
        }
        for suggestion in suggestions {
            context.delete(suggestion)
        }
        for rec in recommendations {
            context.delete(rec)
        }
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func resetUserProfile() {
        if let profile = userProfiles.first {
            context.delete(profile)
        }
        let newProfile = UserProfile()
        context.insert(newProfile)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func clearAllData() {
        // 清空所有数据（危险操作）
        pomodoroSessions.forEach { context.delete($0) }
        todos.forEach { context.delete($0) }
        habits.forEach { context.delete($0) }
        wrongQuestions.forEach { context.delete($0) }
        flashCards.forEach { context.delete($0) }
        suggestions.forEach { context.delete($0) }
        recommendations.forEach { context.delete($0) }
        subjects.forEach { context.delete($0) }
        exams.forEach { context.delete($0) }
        userProfiles.forEach { context.delete($0) }
        
        // 重新初始化用户画像
        let newProfile = UserProfile()
        context.insert(newProfile)
        
        try? context.save()
        HapticManager.shared.success()
    }
}

struct PreferencesDetailView: View {
    @Query private var userProfiles: [UserProfile]
    
    var body: some View {
        NavigationStack {
            List {
                if let profile = userProfiles.first,
                   let preferencesData = profile.recommendationPreferencesData.data(using: .utf8),
                   let preferences = try? JSONDecoder().decode(RecommendationPreferences.self, from: preferencesData) {
                    
                    Section("习惯类型权重") {
                        ForEach(Array(preferences.habitTypeWeights.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                Spacer()
                                Text(String(format: "%.2f", preferences.habitTypeWeights[key] ?? 0.5))
                                    .foregroundColor(weightColor(preferences.habitTypeWeights[key] ?? 0.5))
                            }
                        }
                    }
                    
                    Section("难度偏好权重") {
                        ForEach(Array(preferences.difficultyWeights.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                Spacer()
                                Text(String(format: "%.2f", preferences.difficultyWeights[key] ?? 0.5))
                                    .foregroundColor(weightColor(preferences.difficultyWeights[key] ?? 0.5))
                            }
                        }
                    }
                }
            }
            .navigationTitle("偏好权重详情")
        }
    }
    
    private func weightColor(_ weight: Double) -> Color {
        if weight > 0.7 { return .green }
        if weight < 0.3 { return .red }
        return .orange
    }
}

