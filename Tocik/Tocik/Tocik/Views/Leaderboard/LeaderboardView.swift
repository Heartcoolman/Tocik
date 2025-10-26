//
//  LeaderboardView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  学习排行榜视图
//

import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @State private var selectedPeriod: TimePeriod = .week
    
    enum TimePeriod: String, CaseIterable {
        case day = "今日"
        case week = "本周"
        case month = "本月"
        case all = "总计"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 周期选择器
                Picker("时间周期", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 学习时长排行
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Theme.primaryGradient)
                        Text("学习时长")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        LeaderboardCard(
                            rank: 1,
                            label: "番茄钟",
                            value: "\(periodPomodoroCount)",
                            unit: "个",
                            gradient: Theme.pomodoroGradient
                        )
                        
                        LeaderboardCard(
                            rank: 2,
                            label: "学习时长",
                            value: String(format: "%.1f", Double(periodPomodoroCount) * 0.5),
                            unit: "小时",
                            gradient: Theme.statsGradient
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 任务完成排行
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.todoGradient)
                        Text("任务完成")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        LeaderboardCard(
                            rank: 1,
                            label: "完成任务",
                            value: "\(periodCompletedTodos)",
                            unit: "个",
                            gradient: Theme.todoGradient
                        )
                        
                        LeaderboardCard(
                            rank: 2,
                            label: "完成率",
                            value: String(format: "%.0f", completionRate),
                            unit: "%",
                            gradient: Theme.goalGradient
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 习惯坚持排行
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Theme.habitGradient)
                        Text("习惯坚持")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        LeaderboardCard(
                            rank: 1,
                            label: "最长连续",
                            value: "\(maxStreak)",
                            unit: "天",
                            gradient: Theme.habitGradient
                        )
                        
                        LeaderboardCard(
                            rank: 2,
                            label: "平均连续",
                            value: "\(avgStreak)",
                            unit: "天",
                            gradient: Theme.habitGradient
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 个人最佳记录
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("个人最佳")
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        PersonalBestCard(icon: "timer", label: "单日最多", value: "\(bestDayPomodoros)个番茄钟")
                        PersonalBestCard(icon: "checkmark.circle", label: "单周完成", value: "\(bestWeekTasks)个任务")
                        PersonalBestCard(icon: "flame", label: "连续学习", value: "\(maxStreak)天")
                        PersonalBestCard(icon: "chart.line.uptrend.xyaxis", label: "最高效率", value: "95%")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("学习排行")
    }
    
    // MARK: - 计算属性
    
    private var periodPomodoroCount: Int {
        filteredSessions.count
    }
    
    private var periodCompletedTodos: Int {
        filteredCompletedTodos.count
    }
    
    private var completionRate: Double {
        let total = filteredTodos.count
        let completed = filteredCompletedTodos.count
        return total == 0 ? 0 : Double(completed) / Double(total) * 100
    }
    
    private var maxStreak: Int {
        habits.map { $0.getCurrentStreak() }.max() ?? 0
    }
    
    private var avgStreak: Int {
        let streaks = habits.map { $0.getCurrentStreak() }
        return streaks.isEmpty ? 0 : streaks.reduce(0, +) / streaks.count
    }
    
    private var bestDayPomodoros: Int {
        let grouped = Dictionary(grouping: pomodoroSessions.filter { $0.isCompleted }) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
        return grouped.values.map { $0.count }.max() ?? 0
    }
    
    private var bestWeekTasks: Int {
        // 简化计算
        periodCompletedTodos
    }
    
    private var filteredSessions: [PomodoroSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .day:
            return pomodoroSessions.filter { calendar.isDateInToday($0.startTime) && $0.isCompleted }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return pomodoroSessions.filter { $0.startTime >= weekAgo && $0.isCompleted }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return pomodoroSessions.filter { $0.startTime >= monthAgo && $0.isCompleted }
        case .all:
            return pomodoroSessions.filter { $0.isCompleted }
        }
    }
    
    private var filteredTodos: [TodoItem] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .day:
            return todos.filter { calendar.isDateInToday($0.createdDate) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return todos.filter { $0.createdDate >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return todos.filter { $0.createdDate >= monthAgo }
        case .all:
            return todos
        }
    }
    
    private var filteredCompletedTodos: [TodoItem] {
        filteredTodos.filter { $0.isCompleted }
    }
}

struct LeaderboardCard: View {
    let rank: Int
    let label: String
    let value: String
    let unit: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack {
            // 排名
            Text("#\(rank)")
                .font(.title.bold())
                .foregroundStyle(gradient)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.headline)
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(gradient)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .offset(y: -6)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PersonalBestCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Theme.primaryGradient)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(Theme.primaryGradient)
        }
        .padding()
        .frame(height: 120)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RecordRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Theme.primaryGradient)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Theme.primaryGradient)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

