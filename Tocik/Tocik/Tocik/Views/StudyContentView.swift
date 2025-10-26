//
//  StudyContentView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 全新学习专属界面（方案B：卡片工作区）
//

import SwiftUI
import SwiftData

struct StudyContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad: 卡片工作区
            iPadCardWorkspace()
        } else {
            // iPhone: Tab布局
            iPhoneTabLayout()
        }
    }
}

// MARK: - iPad卡片工作区

struct iPadCardWorkspace: View {
    @Query private var subjects: [Subject]
    @State private var studyMode: StudyMode = .homework
    @State private var selectedTool: ToolItem?
    @State private var showAI = false
    @State private var showSettings = false
    
    enum StudyMode {
        case classMode, homework, review, exam
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 主内容区：卡片布局
                ScrollView {
                    VStack(spacing: 24) {
                        // 学习模式切换器
                        StudyModeSelector(mode: $studyMode)
                        
                        // 科目快捷卡片（横向滚动）
                        SubjectQuickCardsRow()
                        
                        // 当前任务区域（根据模式变化）
                        CurrentTasksCard(mode: studyMode)
                        
                        // 信息卡片网格（3列）
                        InfoCardsGrid()
                        
                        // 工具快捷栏
                        QuickToolsBar(selectedTool: $selectedTool)
                    }
                    .padding()
                }
                
                // 悬浮快捷菜单（右下角）
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionMenu()
                            .padding(32)
                    }
                }
            }
            .navigationTitle("学习中心")
            .navigationDestination(item: $selectedTool) { tool in
                toolDetailView(for: tool)
            }
            .navigationDestination(for: Subject.self) { subject in
                SubjectDetailView(subject: subject)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // 番茄时钟快捷按钮（左侧突出显示）
                    Button(action: {
                        selectedTool = ToolRegistry.tool(for: "pomodoro")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.title3)
                            Text("番茄钟")
                                .font(.headline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.pomodoroGradient)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // 快捷入口组
                        Menu {
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "timetable")
                            }) {
                                Label("今日课程", systemImage: "calendar.day.timeline.left")
                            }
                            
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "todo")
                            }) {
                                Label("待办作业", systemImage: "checklist")
                            }
                            
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "wrong-question")
                            }) {
                                Label("错题复习", systemImage: "exclamationmark.triangle.fill")
                            }
                            
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "exam")
                            }) {
                                Label("备考任务", systemImage: "doc.text.fill")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "flashcard")
                            }) {
                                Label("学习闪卡", systemImage: "rectangle.stack.fill")
                            }
                            
                            Button(action: {
                                selectedTool = ToolRegistry.tool(for: "review-planner")
                            }) {
                                Label("复习计划", systemImage: "arrow.triangle.2.circlepath")
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("快捷")
                                    .font(.subheadline.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Theme.primaryGradient)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        
                        // AI按钮
                        Button(action: { showAI = true }) {
                            Image(systemName: "brain")
                        }
                        
                        // 设置按钮
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAI) {
                AIAssistantView()
            }
            .sheet(isPresented: $showSettings) {
                DataManagementView()
            }
        }
    }
    
    @ViewBuilder
    private func toolDetailView(for tool: ToolItem) -> some View {
        switch tool.id {
        // 核心工具
        case "pomodoro": PomodoroView()
        case "todo": TodoView()
        case "timetable": TimetableView()
        case "calendar": CalendarView()
        case "habit": HabitView()
        case "goal": GoalView()
        // 学习工具
        case "flashcard": FlashCardView()
        case "note": NoteView()
        case "wrong-question": WrongQuestionView()
        case "study-progress": StudyProgressView()
        case "inspiration": InspirationView()
        // 学科工具（新增）
        case "exam": ExamView()
        case "subject": SubjectView()
        case "knowledge-map": KnowledgeMapView()
        case "review-planner": ReviewPlannerView()
        case "study-journal": StudyJournalView()
        case "qa-assistant": QAAssistantView()
        case "leaderboard": LeaderboardView()
        // 智能功能
        case "ai-assistant": AIAssistantView()
        case "achievement": AchievementView()
        case "learning-path": LearningPathView()
        case "personal-growth": PersonalGrowthView()
        case "search": UniversalSearchView()
        case "prediction": TrendPredictionView()
        // 内容工具
        case "reader": ReaderView()
        case "voice": VoiceMemoView()
        // 辅助工具
        case "calculator": CalculatorView()
        case "converter": ConverterView()
        case "focus": FocusModeView()
        case "stats": StatsView()
        case "countdown": CountdownView()
        default: Text("未知功能")
        }
    }
}

// MARK: - iPhone Tab布局

struct iPhoneTabLayout: View {
    var body: some View {
        TabView {
            // Tab 1: 学习
            NavigationStack {
                StudyHomeTab()
            }
            .tabItem {
                Label("学习", systemImage: "book.fill")
            }
            
            // Tab 2: 科目
            NavigationStack {
                SubjectsGridTab()
            }
            .tabItem {
                Label("科目", systemImage: "books.vertical.fill")
            }
            
            // Tab 3: 工具
            NavigationStack {
                ToolsGridTab()
            }
            .tabItem {
                Label("工具", systemImage: "square.grid.2x2")
            }
            
            // Tab 4: 我的
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.circle")
                }
        }
    }
}

// MARK: - iPhone Tabs

struct StudyHomeTab: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var subjects: [Subject]
    @State private var selectedQuickTool: ToolItem? // 用于快捷入口导航
    
    private var todayPomodoros: Int {
        pomodoroSessions.filter {
            Calendar.current.isDateInToday($0.startTime) && $0.isCompleted
        }.count
    }
    
    private var todayTasks: Int {
        todos.filter {
            guard let date = $0.completedDate else { return false }
            return Calendar.current.isDateInToday(date)
        }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 今日概览
                VStack(alignment: .leading, spacing: 16) {
                    Text("今日进度")
                        .font(.title2.bold())
                    
                    HStack(spacing: 16) {
                        TodayStatCard(icon: "timer", label: "番茄钟", value: "\(todayPomodoros)", gradient: Theme.pomodoroGradient)
                        TodayStatCard(icon: "checkmark.circle", label: "完成任务", value: "\(todayTasks)", gradient: Theme.todoGradient)
                    }
                }
                
                // 科目快捷入口
                if !subjects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("我的科目")
                            .font(.headline)
                        
                        ForEach(subjects.prefix(3)) { subject in
                            NavigationLink(value: subject) {
                                HStack {
                                    Image(systemName: subject.icon)
                                        .foregroundColor(Color(hex: subject.colorHex))
                                    Text(subject.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 快捷工具
                VStack(alignment: .leading, spacing: 12) {
                    Text("常用工具")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickToolCard(icon: "note.text", label: "笔记", toolId: "note")
                        QuickToolCard(icon: "rectangle.stack.fill", label: "闪卡", toolId: "flashcard")
                        QuickToolCard(icon: "exclamationmark.triangle.fill", label: "错题", toolId: "wrong-question")
                        QuickToolCard(icon: "target", label: "目标", toolId: "goal")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("学习")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "timetable")
                    }) {
                        Label("今日课程", systemImage: "calendar.day.timeline.left")
                    }
                    
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "todo")
                    }) {
                        Label("待办作业", systemImage: "checklist")
                    }
                    
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "wrong-question")
                    }) {
                        Label("错题复习", systemImage: "exclamationmark.triangle.fill")
                    }
                    
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "exam")
                    }) {
                        Label("备考任务", systemImage: "doc.text.fill")
                    }
                    
                    Divider()
                    
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "flashcard")
                    }) {
                        Label("学习闪卡", systemImage: "rectangle.stack.fill")
                    }
                    
                    Button(action: {
                        selectedQuickTool = ToolRegistry.tool(for: "review-planner")
                    }) {
                        Label("复习计划", systemImage: "arrow.triangle.2.circlepath")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.primaryColor)
                }
            }
        }
        .navigationDestination(for: Subject.self) { subject in
            SubjectDetailView(subject: subject)
        }
        .navigationDestination(item: $selectedQuickTool) { tool in
            StudyContentViewHelpers.toolDetailView(for: tool)
        }
    }
}

struct TodayStatCard: View {
    let icon: String
    let label: String
    let value: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(gradient)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct QuickToolCard: View {
    let icon: String
    let label: String
    let toolId: String
    
    var body: some View {
        NavigationLink(value: ToolRegistry.tool(for: toolId)!) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(Theme.primaryGradient)
                Text(label)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct SubjectsGridTab: View {
    @Query private var subjects: [Subject]
    @State private var showAddSubject = false
    @State private var selectedSubject: Subject?
    
    var body: some View {
        Group {
            if let subject = selectedSubject {
                SubjectDetailView(subject: subject)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                selectedSubject = nil
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("返回")
                                }
                            }
                        }
                    }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(subjects) { subject in
                            Button(action: {
                                selectedSubject = subject
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: subject.icon)
                                            .font(.title2)
                                            .foregroundColor(Color(hex: subject.colorHex))
                                        Spacer()
                                    }
                                    
                                    Text(subject.name)
                                        .font(.headline)
                                    
                                    Text(String(format: "%.1fh", subject.totalStudyHours))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(hex: subject.colorHex).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                
                        // 添加按钮
                        Button(action: { showAddSubject = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(Theme.primaryGradient)
                                Text("添加科目")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
                .navigationTitle("我的科目")
                .sheet(isPresented: $showAddSubject) {
                    AddSubjectView()
                }
            }
        }
    }
}

struct ToolsGridTab: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 学习工具
                VStack(alignment: .leading, spacing: 12) {
                    Text("学习工具")
                        .font(.title2.bold())
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ToolRegistry.studyTools) { tool in
                            NavigationLink(value: tool) {
                                VStack(spacing: 8) {
                                    Image(systemName: tool.icon)
                                        .font(.title)
                                        .foregroundColor(tool.color)
                                    Text(tool.name)
                                        .font(.caption.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 学科工具
                VStack(alignment: .leading, spacing: 12) {
                    Text("学科工具")
                        .font(.title2.bold())
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ToolRegistry.subjectTools) { tool in
                            NavigationLink(value: tool) {
                                VStack(spacing: 8) {
                                    Image(systemName: tool.icon)
                                        .font(.title)
                                        .foregroundColor(tool.color)
                                    Text(tool.name)
                                        .font(.caption.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("工具")
        .navigationDestination(for: ToolItem.self) { tool in
            StudyContentViewHelpers.toolDetailView(for: tool)
        }
    }
}

// MARK: - 辅助函数

struct StudyContentViewHelpers {
    @ViewBuilder
    static func toolDetailView(for tool: ToolItem) -> some View {
        switch tool.id {
        // 核心工具
        case "pomodoro": PomodoroView()
        case "todo": TodoView()
        case "timetable": TimetableView()
        case "calendar": CalendarView()
        case "habit": HabitView()
        case "goal": GoalView()
        // 学习工具
        case "flashcard": FlashCardView()
        case "note": NoteView()
        case "wrong-question": WrongQuestionView()
        case "study-progress": StudyProgressView()
        case "inspiration": InspirationView()
        // 学科工具
        case "exam": ExamView()
        case "subject": SubjectView()
        case "knowledge-map": KnowledgeMapView()
        case "review-planner": ReviewPlannerView()
        case "study-journal": StudyJournalView()
        case "qa-assistant": QAAssistantView()
        case "leaderboard": LeaderboardView()
        // 智能功能
        case "ai-assistant": AIAssistantView()
        case "achievement": AchievementView()
        case "learning-path": LearningPathView()
        case "personal-growth": PersonalGrowthView()
        case "search": UniversalSearchView()
        case "prediction": TrendPredictionView()
        // 内容工具
        case "reader": ReaderView()
        case "voice": VoiceMemoView()
        // 辅助工具
        case "calculator": CalculatorView()
        case "converter": ConverterView()
        case "focus": FocusModeView()
        case "stats": StatsView()
        case "countdown": CountdownView()
        default: Text("未知功能")
        }
    }
}

