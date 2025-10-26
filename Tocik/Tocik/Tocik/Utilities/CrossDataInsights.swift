//
//  CrossDataInsights.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 跨数据关联分析引擎（优化6）
//

import Foundation
import SwiftData

/// 跨数据源关联分析 - 发现单一分析无法发现的深层问题
class CrossDataInsights {
    
    /// 执行全面的跨数据关联分析
    static func findCorrelations(
        subjects: [Subject],
        exams: [Exam],
        notes: [Note],
        wrongQuestions: [WrongQuestion],
        reviewPlans: [ReviewPlan],
        pomodoroSessions: [PomodoroSession],
        todos: [TodoItem],
        courses: [CourseItem],
        calendarEvents: [CalendarEvent]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        
        // 1. 科目 × 错题 × 学习时长
        insights.append(contentsOf: analyzeSubjectWeakness(
            subjects: subjects,
            wrongQuestions: wrongQuestions,
            sessions: pomodoroSessions
        ))
        
        // 2. 考试 × 复习计划 × 时间压力
        insights.append(contentsOf: analyzeExamPreparation(
            exams: exams,
            reviewPlans: reviewPlans,
            todos: todos
        ))
        
        // 3. 专注度 × 任务完成率
        insights.append(contentsOf: analyzeFocusImpact(
            sessions: pomodoroSessions,
            todos: todos
        ))
        
        // 4. 课程安排 × 日历冲突
        insights.append(contentsOf: analyzeScheduleConflicts(
            courses: courses,
            events: calendarEvents,
            exams: exams
        ))
        
        // 5. 笔记质量 × 知识掌握
        insights.append(contentsOf: analyzeNoteEffectiveness(
            notes: notes,
            wrongQuestions: wrongQuestions,
            subjects: subjects
        ))
        
        // 6. 复习计划 × 实际执行
        insights.append(contentsOf: analyzeReviewExecution(
            reviewPlans: reviewPlans,
            sessions: pomodoroSessions
        ))
        
        return insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - 分析函数
    
    /// 分析1: 科目薄弱点关联
    private static func analyzeSubjectWeakness(
        subjects: [Subject],
        wrongQuestions: [WrongQuestion],
        sessions: [PomodoroSession]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        for subject in subjects {
            // 错题数量
            let subjectWrongQuestions = wrongQuestions.filter { 
                $0.subjectId == subject.id && $0.masteryLevel != .mastered 
            }
            
            // 学习时长
            let subjectSessions = sessions.filter { 
                $0.subjectId == subject.id && $0.startTime >= weekAgo 
            }
            let weeklyHours = Double(subjectSessions.count) * 0.5
            
            // 关联洞察：错题多 + 学习少 = 需要加强
            if subjectWrongQuestions.count >= 5 && weeklyHours < 2.0 {
                insights.append(CrossDataInsight(
                    title: "\(subject.name)需要重点关注",
                    description: "该科目有\(subjectWrongQuestions.count)道未掌握错题，但本周仅学习\(String(format: "%.1f", weeklyHours))小时",
                    suggestion: "建议每周增加2-3个番茄钟专项复习，优先攻克错题",
                    priority: .high,
                    category: .subjectWeakness,
                    relatedData: ["subject": subject.name, "wrongQuestions": subjectWrongQuestions.count]
                ))
            }
            
            // 关联洞察：学习多但错题仍多 = 方法问题
            if subjectWrongQuestions.count >= 5 && weeklyHours >= 5.0 {
                insights.append(CrossDataInsight(
                    title: "\(subject.name)学习方法需要调整",
                    description: "已投入\(String(format: "%.1f", weeklyHours))小时，但仍有\(subjectWrongQuestions.count)道错题",
                    suggestion: "建议调整学习策略：增加错题分析时间，寻找知识点薄弱环节",
                    priority: .medium,
                    category: .studyMethod,
                    relatedData: ["subject": subject.name]
                ))
            }
        }
        
        return insights
    }
    
    /// 分析2: 考试备考压力
    private static func analyzeExamPreparation(
        exams: [Exam],
        reviewPlans: [ReviewPlan],
        todos: [TodoItem]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        
        let upcomingExams = exams.filter { !$0.isFinished }.sorted { $0.examDate < $1.examDate }
        
        for exam in upcomingExams.prefix(3) {
            let daysLeft = exam.daysRemaining()
            
            // 找到相关的复习计划
            let relatedPlans = reviewPlans.filter { 
                $0.subject == exam.subject && $0.status == .active 
            }
            
            // 找到相关的待办任务
            let relatedTodos = todos.filter { 
                !$0.isCompleted && $0.title.contains(exam.subject)
            }
            
            // 关联洞察：考试临近 + 无复习计划 = 准备不足
            if daysLeft <= 14 && relatedPlans.isEmpty {
                insights.append(CrossDataInsight(
                    title: "\(exam.examName)备考计划缺失",
                    description: "考试还剩\(daysLeft)天，但尚未制定复习计划",
                    suggestion: "立即创建复习计划，每天至少2小时专项复习",
                    priority: daysLeft <= 7 ? .urgent : .high,
                    category: .examPreparation,
                    relatedData: ["exam": exam.examName, "daysLeft": daysLeft]
                ))
            }
            
            // 关联洞察：考试临近 + 复习进度慢 = 时间紧张
            if daysLeft <= 7 && !relatedPlans.isEmpty {
                let avgProgress = relatedPlans.map { $0.progress() }.reduce(0, +) / Double(relatedPlans.count)
                
                if avgProgress < 0.5 {
                    insights.append(CrossDataInsight(
                        title: "\(exam.examName)复习进度落后",
                        description: "还剩\(daysLeft)天，但复习计划仅完成\(Int(avgProgress * 100))%",
                        suggestion: "建议每天增加1-2小时复习时间，重点突破未完成内容",
                        priority: .urgent,
                        category: .examPreparation,
                        relatedData: ["exam": exam.examName, "progress": avgProgress]
                    ))
                }
            }
            
            // 关联洞察：考试临近 + 待办任务多 = 时间冲突
            if daysLeft <= 7 && relatedTodos.count >= 3 {
                insights.append(CrossDataInsight(
                    title: "备考与作业时间冲突",
                    description: "\(exam.examName)临近，但还有\(relatedTodos.count)个\(exam.subject)相关任务未完成",
                    suggestion: "优先完成考试相关任务，其他任务可适当延后",
                    priority: .high,
                    category: .timeConflict,
                    relatedData: ["exam": exam.examName, "todos": relatedTodos.count]
                ))
            }
        }
        
        return insights
    }
    
    /// 分析3: 专注度对任务完成的影响
    private static func analyzeFocusImpact(
        sessions: [PomodoroSession],
        todos: [TodoItem]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let recentSessions = sessions.filter { $0.startTime >= weekAgo && $0.isCompleted }
        let avgFocusScore = recentSessions.isEmpty ? 0 : recentSessions.map { $0.focusScore }.reduce(0, +) / Double(recentSessions.count)
        let avgInterruptions = recentSessions.isEmpty ? 0 : Double(recentSessions.map { $0.interruptionCount }.reduce(0, +)) / Double(recentSessions.count)
        
        let recentTodos = todos.filter { $0.createdDate >= weekAgo }
        let completionRate = recentTodos.isEmpty ? 0 : Double(recentTodos.filter { $0.isCompleted }.count) / Double(recentTodos.count)
        
        // 关联洞察：低专注度 + 低完成率 = 干扰太多
        if avgFocusScore < 70 && avgInterruptions > 3 && completionRate < 0.5 {
            insights.append(CrossDataInsight(
                title: "频繁中断影响任务完成",
                description: "平均专注度\(Int(avgFocusScore))分，每个番茄钟被中断\(String(format: "%.1f", avgInterruptions))次，导致任务完成率仅\(Int(completionRate * 100))%",
                suggestion: "开启免打扰模式，将手机放远，创造更好的学习环境",
                priority: .high,
                category: .focusImprovement,
                relatedData: ["focusScore": avgFocusScore, "interruptions": avgInterruptions]
            ))
        }
        
        return insights
    }
    
    /// 分析4: 日程冲突检测
    private static func analyzeScheduleConflicts(
        courses: [CourseItem],
        events: [CalendarEvent],
        exams: [Exam]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        let upcomingEvents = events.filter { $0.startDate <= nextWeek && $0.startDate >= Date() }
        let upcomingExams = exams.filter { !$0.isFinished && $0.examDate <= nextWeek }
        
        // 计算本周总课时
        let today = Calendar.current.component(.weekday, from: Date())
        let thisWeekCourses = courses.filter { $0.weekday >= today }
        
        // 关联洞察：课程密集 + 考试临近 + 活动多 = 时间紧张
        if thisWeekCourses.count >= 15 && !upcomingExams.isEmpty && upcomingEvents.count >= 3 {
            insights.append(CrossDataInsight(
                title: "下周时间安排过于紧张",
                description: "有\(thisWeekCourses.count)节课程、\(upcomingExams.count)场考试、\(upcomingEvents.count)个活动",
                suggestion: "建议取消非必要活动，集中精力应对考试和课程",
                priority: .high,
                category: .timeManagement,
                relatedData: ["courses": thisWeekCourses.count, "exams": upcomingExams.count]
            ))
        }
        
        return insights
    }
    
    /// 分析5: 笔记有效性
    private static func analyzeNoteEffectiveness(
        notes: [Note],
        wrongQuestions: [WrongQuestion],
        subjects: [Subject]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        
        for subject in subjects {
            let subjectNotes = notes.filter { $0.subjectId == subject.id }
            let subjectWrongQuestions = wrongQuestions.filter { 
                $0.subjectId == subject.id && $0.masteryLevel != .mastered 
            }
            
            // 关联洞察：笔记少 + 错题多 = 知识记录不足
            if subjectNotes.count < 3 && subjectWrongQuestions.count >= 5 {
                insights.append(CrossDataInsight(
                    title: "\(subject.name)知识记录不足",
                    description: "仅有\(subjectNotes.count)篇笔记，但有\(subjectWrongQuestions.count)道错题",
                    suggestion: "建议增加笔记记录，整理错题知识点，构建知识体系",
                    priority: .medium,
                    category: .knowledgeManagement,
                    relatedData: ["subject": subject.name]
                ))
            }
        }
        
        return insights
    }
    
    /// 分析6: 复习计划执行情况
    private static func analyzeReviewExecution(
        reviewPlans: [ReviewPlan],
        sessions: [PomodoroSession]
    ) -> [CrossDataInsight] {
        var insights: [CrossDataInsight] = []
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        let activePlans = reviewPlans.filter { $0.status == .active }
        
        for plan in activePlans {
            let planSessions = sessions.filter { 
                $0.startTime >= weekAgo && $0.note.contains(plan.planName)
            }
            
            // 关联洞察：复习计划存在 + 无执行记录 = 计划搁置
            if plan.progress() < 0.2 && planSessions.isEmpty {
                insights.append(CrossDataInsight(
                    title: "复习计划未执行",
                    description: "\(plan.planName)进度仅\(Int(plan.progress() * 100))%，本周无相关学习记录",
                    suggestion: "建议为复习计划设置固定时间段，或调整计划难度",
                    priority: .medium,
                    category: .planExecution,
                    relatedData: ["plan": plan.planName]
                ))
            }
        }
        
        return insights
    }
}

// MARK: - 数据结构

struct CrossDataInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let suggestion: String
    let priority: InsightPriority
    let category: InsightCategory
    let relatedData: [String: Any]
    let discoveredDate = Date()
    
    enum InsightPriority: Int {
        case urgent = 3
        case high = 2
        case medium = 1
        case low = 0
    }
    
    enum InsightCategory: String {
        case subjectWeakness = "科目薄弱"
        case examPreparation = "考试准备"
        case focusImprovement = "专注提升"
        case timeConflict = "时间冲突"
        case timeManagement = "时间管理"
        case knowledgeManagement = "知识管理"
        case studyMethod = "学习方法"
        case planExecution = "计划执行"
    }
}

