//
//  StudyDataViewModel.swift
//  Tocik
//
//  Created: 2025/10/24
//  学习数据视图模型 - 统一管理和缓存学习相关数据
//

import Foundation
import SwiftData
import Combine
import os

/// 学习数据视图模型 - 减少重复的@Query查询，提供统一的数据访问接口
@MainActor
class StudyDataViewModel: ObservableObject {
    
    // MARK: - 发布的数据
    
    @Published var pomodoroSessions: [PomodoroSession] = []
    @Published var todos: [TodoItem] = []
    @Published var habits: [Habit] = []
    @Published var goals: [Goal] = []
    @Published var subjects: [Subject] = []
    @Published var exams: [Exam] = []
    @Published var wrongQuestions: [WrongQuestion] = []
    @Published var flashCards: [FlashCard] = []
    @Published var notes: [Note] = []
    @Published var reviewPlans: [ReviewPlan] = []
    
    // 缓存状态
    @Published var isLoading = false
    @Published var lastRefreshTime: Date?
    @Published var cacheHitRate: Double = 0.0
    
    // MARK: - 私有属性
    
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    // 缓存配置
    private let cacheTimeout: TimeInterval = 300 // 5分钟
    private var cacheHits = 0
    private var cacheMisses = 0
    
    // MARK: - 初始化
    
    init() {
        AppLogger.database.info("📦 StudyDataViewModel 初始化")
    }
    
    // MARK: - 数据加载
    
    /// 配置数据上下文
    func configure(with context: ModelContext) {
        self.modelContext = context
        AppLogger.database.debug("✅ StudyDataViewModel 已配置 ModelContext")
    }
    
    /// 加载所有数据
    func loadAllData() async {
        guard let context = modelContext else {
            AppLogger.database.warning("⚠️ ModelContext 未配置")
            return
        }
        
        // 检查缓存是否有效
        if isCacheValid() {
            AppLogger.database.debug("🎯 使用缓存数据")
            cacheHits += 1
            updateCacheHitRate()
            return
        }
        
        isLoading = true
        cacheMisses += 1
        updateCacheHitRate()
        
        let startTime = Date()
        
        do {
            // 并发加载所有数据
            async let pomodoroData = fetchPomodoros(context)
            async let todosData = fetchTodos(context)
            async let habitsData = fetchHabits(context)
            async let goalsData = fetchGoals(context)
            async let subjectsData = fetchSubjects(context)
            async let examsData = fetchExams(context)
            async let wrongQuestionsData = fetchWrongQuestions(context)
            async let flashCardsData = fetchFlashCards(context)
            async let notesData = fetchNotes(context)
            async let reviewPlansData = fetchReviewPlans(context)
            
            // 等待所有数据加载完成
            let results = try await (
                pomodoroData, todosData, habitsData, goalsData, subjectsData,
                examsData, wrongQuestionsData, flashCardsData, notesData, reviewPlansData
            )
            
            // 更新发布的数据
            pomodoroSessions = results.0
            todos = results.1
            habits = results.2
            goals = results.3
            subjects = results.4
            exams = results.5
            wrongQuestions = results.6
            flashCards = results.7
            notes = results.8
            reviewPlans = results.9
            
            lastRefreshTime = Date()
            
            let duration = Date().timeIntervalSince(startTime)
            AppLogger.database.info("✅ 数据加载完成 - 耗时: \(String(format: "%.3fs", duration))")
            
        } catch {
            AppLogger.database.error("❌ 数据加载失败: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// 刷新特定类型的数据
    func refresh<T: PersistentModel>(_ type: T.Type) async {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<T>()
            let data = try context.fetch(descriptor)
            
            // 根据类型更新对应的属性
            switch type {
            case is PomodoroSession.Type:
                pomodoroSessions = data as? [PomodoroSession] ?? []
            case is TodoItem.Type:
                todos = data as? [TodoItem] ?? []
            case is Habit.Type:
                habits = data as? [Habit] ?? []
            case is Goal.Type:
                goals = data as? [Goal] ?? []
            default:
                break
            }
            
            AppLogger.database.debug("🔄 \(String(describing: type)) 数据已刷新")
        } catch {
            AppLogger.database.error("❌ 刷新失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 缓存管理
    
    private func isCacheValid() -> Bool {
        guard let lastRefresh = lastRefreshTime else {
            return false
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        return timeSinceRefresh < cacheTimeout
    }
    
    /// 强制刷新缓存
    func invalidateCache() {
        lastRefreshTime = nil
        AppLogger.database.debug("🗑️ 缓存已失效")
    }
    
    private func updateCacheHitRate() {
        let total = cacheHits + cacheMisses
        cacheHitRate = total > 0 ? Double(cacheHits) / Double(total) : 0.0
        AppLogger.performance.info("📊 缓存命中率: \(String(format: "%.1f%%", self.cacheHitRate * 100))")
    }
    
    // MARK: - 数据获取方法
    
    private func fetchPomodoros(_ context: ModelContext) async throws -> [PomodoroSession] {
        let descriptor = FetchDescriptor<PomodoroSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    private func fetchTodos(_ context: ModelContext) async throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    private func fetchHabits(_ context: ModelContext) async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return try context.fetch(descriptor)
    }
    
    private func fetchGoals(_ context: ModelContext) async throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>()
        return try context.fetch(descriptor)
    }
    
    private func fetchSubjects(_ context: ModelContext) async throws -> [Subject] {
        let descriptor = FetchDescriptor<Subject>()
        return try context.fetch(descriptor)
    }
    
    private func fetchExams(_ context: ModelContext) async throws -> [Exam] {
        let descriptor = FetchDescriptor<Exam>(
            sortBy: [SortDescriptor(\.examDate)]
        )
        return try context.fetch(descriptor)
    }
    
    private func fetchWrongQuestions(_ context: ModelContext) async throws -> [WrongQuestion] {
        let descriptor = FetchDescriptor<WrongQuestion>(
            sortBy: [SortDescriptor(\WrongQuestion.createdDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    private func fetchFlashCards(_ context: ModelContext) async throws -> [FlashCard] {
        let descriptor = FetchDescriptor<FlashCard>()
        return try context.fetch(descriptor)
    }
    
    private func fetchNotes(_ context: ModelContext) async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    private func fetchReviewPlans(_ context: ModelContext) async throws -> [ReviewPlan] {
        let descriptor = FetchDescriptor<ReviewPlan>()
        return try context.fetch(descriptor)
    }
    
    // MARK: - 便捷计算属性
    
    /// 今日完成的番茄钟数量
    var todayPomodoroCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return pomodoroSessions.filter { session in
            Calendar.current.isDate(session.startTime, inSameDayAs: today) && session.isCompleted
        }.count
    }
    
    /// 未完成的待办事项数量
    var incompleteTodoCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    /// 逾期的待办事项
    var overdueTodos: [TodoItem] {
        todos.filter { todo in
            if let dueDate = todo.dueDate {
                return !todo.isCompleted && dueDate < Date()
            }
            return false
        }
    }
    
    /// 今日需要打卡的习惯
    var pendingHabitsToday: [Habit] {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.filter { habit in
            // 检查今天是否已经有完成记录
            !habit.records.contains { record in
                Calendar.current.isDate(record.date, inSameDayAs: today)
            }
        }
    }
    
    /// 近期考试（7天内）
    var upcomingExams: [Exam] {
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return exams.filter { exam in
            !exam.isFinished && exam.examDate <= sevenDaysLater && exam.examDate >= Date()
        }
    }
}

