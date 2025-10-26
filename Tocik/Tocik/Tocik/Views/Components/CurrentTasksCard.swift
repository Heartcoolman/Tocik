//
//  CurrentTasksCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  当前任务卡片（根据学习模式变化）
//

import SwiftUI
import SwiftData

struct CurrentTasksCard: View {
    let mode: iPadCardWorkspace.StudyMode
    @Query private var todos: [TodoItem]
    @State private var showPomodoro = false
    @State private var selectedTask: String? = nil
    @State private var showFullView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(modeTitle)
                    .font(.title2.bold())
                Spacer()
                Button("查看全部") { 
                    showFullView = true
                }
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            // 根据模式显示不同任务
            Group {
                switch mode {
                case .classMode:
                    ClassTasksList(onStartTask: startTask)
                case .homework:
                    HomeworkTasksList(onStartTask: startTask)
                case .review:
                    ReviewTasksList(onStartTask: startTask)
                case .exam:
                    ExamPrepList(onStartTask: startTask)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .sheet(isPresented: $showPomodoro) {
            PomodoroView()
        }
        .sheet(isPresented: $showFullView) {
            fullViewForMode
        }
    }
    
    private func startTask(_ taskName: String) {
        selectedTask = taskName
        showPomodoro = true
    }
    
    @ViewBuilder
    private var fullViewForMode: some View {
        switch mode {
        case .classMode:
            NavigationStack {
                TimetableView()
            }
        case .homework:
            NavigationStack {
                TodoView()
            }
        case .review:
            NavigationStack {
                FlashCardView()
            }
        case .exam:
            NavigationStack {
                ExamView()
            }
        }
    }
    
    private var modeTitle: String {
        switch mode {
        case .classMode: return "📖 今日课程"
        case .homework: return "✍️ 进行中的作业"
        case .review: return "📝 待复习内容"
        case .exam: return "🎯 备考任务"
        }
    }
}

// MARK: - 不同模式的任务列表

struct ClassTasksList: View {
    @Query private var courses: [CourseItem]
    let onStartTask: (String) -> Void
    
    private var todayCourses: [CourseItem] {
        let today = Calendar.current.component(.weekday, from: Date())
        return courses.filter { $0.weekday == today }
            .sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(todayCourses.prefix(5)) { course in
                TaskRow(
                    icon: "book.fill",
                    title: "\(course.courseName)",
                    status: course.location.isEmpty ? "今日课程" : course.location,
                    onStart: { onStartTask(course.courseName) }
                )
            }
            
            if todayCourses.isEmpty {
                EmptyTasksView(message: "今天没有课程安排")
            }
        }
    }
}

struct HomeworkTasksList: View {
    @Query(filter: #Predicate<TodoItem> { !$0.isCompleted })
    private var incompleteTodos: [TodoItem]
    let onStartTask: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(incompleteTodos.prefix(5)) { todo in
                TaskRow(
                    icon: "circle",
                    title: todo.title,
                    status: "\(todo.pomodoroCount)/\(todo.estimatedPomodoros)番茄钟",
                    onStart: { onStartTask(todo.title) }
                )
            }
            
            if incompleteTodos.isEmpty {
                EmptyTasksView(message: "太棒了！没有待办作业")
            }
        }
    }
}

struct ReviewTasksList: View {
    @Query private var flashCards: [FlashCard]
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var reviewPlans: [ReviewPlan]
    let onStartTask: (String) -> Void
    
    private var needReviewCards: Int {
        flashCards.filter { $0.nextReviewDate <= Date() }.count
    }
    
    private var needReviewWrongQuestions: Int {
        wrongQuestions.filter { $0.nextReviewDate <= Date() && $0.masteryLevel != .mastered }.count
    }
    
    private var activePlans: [ReviewPlan] {
        reviewPlans.filter { $0.status == .active }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 待复习闪卡
            if needReviewCards > 0 {
                TaskRow(
                    icon: "rectangle.stack.fill",
                    title: "待复习闪卡",
                    status: "\(needReviewCards)张",
                    onStart: { onStartTask("复习闪卡") }
                )
            }
            
            // 待复习错题
            if needReviewWrongQuestions > 0 {
                TaskRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "待复习错题",
                    status: "\(needReviewWrongQuestions)道",
                    onStart: { onStartTask("复习错题") }
                )
            }
            
            // 复习计划
            ForEach(activePlans.prefix(3)) { plan in
                TaskRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: plan.planName,
                    status: "\(plan.subject) - \(Int(plan.progress() * 100))%",
                    onStart: { onStartTask(plan.planName) }
                )
            }
            
            if needReviewCards == 0 && needReviewWrongQuestions == 0 && activePlans.isEmpty {
                EmptyTasksView(message: "暂无待复习内容")
            }
        }
    }
}

struct ExamPrepList: View {
    @Query private var exams: [Exam]
    let onStartTask: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(exams.filter { !$0.isFinished }.prefix(3)) { exam in
                TaskRow(
                    icon: "doc.text.fill",
                    title: "\(exam.examName) - \(exam.subject)",
                    status: "还剩\(exam.daysRemaining())天",
                    onStart: { onStartTask("\(exam.examName)备考") }
                )
            }
            
            if exams.filter({ !$0.isFinished }).isEmpty {
                EmptyTasksView(message: "暂无即将到来的考试")
            }
        }
    }
}

struct TaskRow: View {
    let icon: String
    let title: String
    let status: String
    var onStart: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                onStart?()
                HapticManager.shared.success()
            }) {
                Text("开始")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.primaryGradient)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

struct EmptyTasksView: View {
    let message: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

