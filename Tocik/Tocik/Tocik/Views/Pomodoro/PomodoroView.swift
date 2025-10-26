//
//  PomodoroView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct PomodoroView: View {
    @StateObject private var timer = PomodoroTimer()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var sessions: [PomodoroSession]
    @Query(filter: #Predicate<TodoItem> { !$0.isCompleted }) private var activeTodos: [TodoItem]
    @Query private var subjects: [Subject] // v5.0: 科目列表
    
    @State private var selectedTodo: TodoItem?
    @State private var selectedSubject: Subject? // v5.0: 选中的科目
    @State private var showTodoList = false
    @State private var showSubjectList = false // v5.0: 显示科目选择
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景设计
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    // 渐变背景
                    Theme.pomodoroGradient
                        .opacity(0.15)
                        .blur(radius: 100)
                        .ignoresSafeArea()
                    
                    // 装饰圆圈
                    if timer.isRunning {
                        Circle()
                            .fill(Theme.pomodoroColor.opacity(0.1))
                            .frame(width: 400, height: 400)
                            .blur(radius: 50)
                            .scaleEffect(timer.isRunning ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: timer.isRunning)
                    }
                }
                
                VStack(spacing: Theme.spacing.xlarge) {
                    // 锁定提示（运行时显示）
                    if timer.isRunning {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("专注模式已锁定，暂停后可返回")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 模式标题
                    Text(timer.currentMode.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.pomodoroGradient)
                    
                    // 现代化圆形进度条
                    ZStack {
                        // 进度圈
                        CircularProgressView(
                            progress: timer.progress,
                            gradient: Theme.pomodoroGradient,
                            lineWidth: 24,
                            showGlow: timer.isRunning
                        )
                        .frame(width: 300, height: 300)
                        
                        // 中心内容
                        VStack(spacing: Theme.spacing.medium) {
                            Text(timer.formatTime())
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.pomodoroGradient)
                            
                            Text(timer.currentMode.emoji)
                                .font(.system(size: 48))
                        }
                    }
                    .padding()
                    
                    // 现代化控制按钮
                    HStack(spacing: Theme.spacing.large) {
                        // 重置按钮
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            timer.reset()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Theme.pomodoroColor)
                                .frame(width: 64, height: 64)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Theme.pomodoroColor.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                        
                        // 主按钮（开始/暂停）
                        FloatingButton(
                            icon: timer.isRunning ? "pause.fill" : "play.fill",
                            gradient: Theme.pomodoroGradient,
                            action: {
                                if timer.isRunning {
                                    timer.pause()
                                } else {
                                    timer.start()
                                }
                            }
                        )
                        .scaleEffect(1.15)
                        
                        // 跳过按钮
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            timer.skip()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Theme.pomodoroColor)
                                .frame(width: 64, height: 64)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Theme.pomodoroColor.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                    }
                    .padding()
                    
                    // 关联区域（待办和科目）
                    VStack(spacing: 12) {
                        // 关联待办（玻璃态设计）
                        if let todo = selectedTodo {
                            GlassCard(cornerRadius: Theme.cornerRadius) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("正在进行")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(todo.title)
                                            .font(Theme.bodyFont)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { 
                                        withAnimation(Theme.smoothAnimation) {
                                            selectedTodo = nil
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 24))
                                    }
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else if !activeTodos.isEmpty {
                            Button(action: { showTodoList = true }) {
                                Label("关联待办事项", systemImage: "checklist")
                                    .font(Theme.bodyFont)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.todoGradient)
                                    .cornerRadius(Theme.cornerRadius)
                                    .shadow(color: Theme.todoColor.opacity(0.3), radius: 15, y: 8)
                            }
                        }
                        
                        // v5.0: 关联科目
                        if let subject = selectedSubject {
                            GlassCard(cornerRadius: Theme.cornerRadius) {
                                HStack {
                                    Image(systemName: subject.icon)
                                        .font(.title3)
                                        .foregroundColor(Color(hex: subject.colorHex))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("学习科目")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(subject.name)
                                            .font(Theme.bodyFont)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { 
                                        withAnimation(Theme.smoothAnimation) {
                                            selectedSubject = nil
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 24))
                                    }
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else if !subjects.isEmpty {
                            Button(action: { showSubjectList = true }) {
                                Label("选择学习科目", systemImage: "books.vertical")
                                    .font(Theme.bodyFont)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "#667EEA"), Color(hex: "#764BA2")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(Theme.cornerRadius)
                                    .shadow(color: Color(hex: "#667EEA").opacity(0.3), radius: 15, y: 8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 今日统计（玻璃态卡片）
                    HStack(spacing: Theme.spacing.medium) {
                        ModernStatItem(
                            title: "今日完成",
                            value: "\(todayCompletedSessions)",
                            icon: "checkmark.circle.fill",
                            gradient: Theme.statsGradient
                        )
                        
                        ModernStatItem(
                            title: "本周完成",
                            value: "\(weekCompletedSessions)",
                            icon: "chart.bar.fill",
                            gradient: Theme.primaryGradient
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("番茄时钟")
            .navigationBarBackButtonHidden(timer.isRunning)
            .interactiveDismissDisabled(timer.isRunning)
            .sheet(isPresented: $showTodoList) {
                TodoSelectionView(selectedTodo: $selectedTodo, todos: activeTodos)
            }
            .sheet(isPresented: $showSubjectList) {
                SubjectSelectionView(selectedSubject: $selectedSubject, subjects: subjects)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PomodoroStatsView()) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(Theme.pomodoroColor)
                    }
                }
            }
            .onChange(of: timer.sessionsCompleted) { oldValue, newValue in
                if newValue > oldValue {
                    saveSession()
                    
                    // 如果关联了待办，增加番茄钟计数
                    if let todo = selectedTodo {
                        todo.pomodoroCount += 1
                    }
                    
                    // v5.0: 如果关联了科目，更新科目统计
                    if let subject = selectedSubject {
                        let studyHours = Double(timer.currentMode.duration) / 60.0
                        subject.updateStats(
                            studyHours: studyHours,
                            pomodoros: 1
                        )
                    }
                    
                    try? modelContext.save()
                }
            }
        }
    }
    
    private var todayCompletedSessions: Int {
        sessions.filter { session in
            session.sessionType == .work && 
            session.isCompleted && 
            session.startTime.isToday
        }.count
    }
    
    private var weekCompletedSessions: Int {
        sessions.filter { session in
            session.sessionType == .work && 
            session.isCompleted && 
            session.startTime.isThisWeek
        }.count
    }
    
    private func saveSession() {
        let session = PomodoroSession(
            startTime: Date().addingTimeInterval(-Double(timer.currentMode.duration)),
            endTime: Date(),
            sessionType: timer.currentMode == .work ? .work : (timer.currentMode == .shortBreak ? .shortBreak : .longBreak),
            isCompleted: true,
            subjectId: selectedSubject?.id // v5.0: 保存关联的科目ID
        )
        modelContext.insert(session)
        try? modelContext.save()
    }
}

struct PomodoroStatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.pomodoroColor)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Theme.pomodoroColor)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PomodoroView()
        .modelContainer(for: PomodoroSession.self, inMemory: true)
}

