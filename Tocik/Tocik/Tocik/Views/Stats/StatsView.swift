//
//  StatsView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var events: [CalendarEvent]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.xlarge) {
                    // 圆环仪表盘（Apple Watch风格）
                    VStack(spacing: Theme.spacing.large) {
                        Text("今日概览")
                            .font(Theme.titleFont)
                        
                        ZStack {
                            // 番茄钟圆环
                            CircularProgressView(
                                progress: min(Double(todayPomodoroCount) / 8.0, 1.0),
                                gradient: Theme.pomodoroGradient,
                                lineWidth: 16,
                                showGlow: true
                            )
                            .frame(width: 200, height: 200)
                            
                            VStack(spacing: 8) {
                                Text("\(todayPomodoroCount)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.pomodoroGradient)
                                
                                Text("个番茄钟")
                                    .font(Theme.captionFont)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.heroCornerRadius))
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    .padding(.horizontal)
                    
                    // 统计卡片网格
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                        ModernOverviewCard(
                            title: "待办完成率",
                            value: "\(todoCompletionRate)%",
                            icon: "checklist",
                            gradient: Theme.todoGradient
                        )
                        
                        ModernOverviewCard(
                            title: "习惯打卡",
                            value: "\(habitsCheckedToday)",
                            icon: "chart.line.uptrend.xyaxis",
                            gradient: Theme.habitGradient
                        )
                        
                        ModernOverviewCard(
                            title: "即将事件",
                            value: "\(upcomingEventsCount)",
                            icon: "calendar",
                            gradient: Theme.calendarGradient
                        )
                        
                        ModernOverviewCard(
                            title: "本周学习",
                            value: "\(weeklyStudyHours)h",
                            icon: "book.fill",
                            gradient: Theme.flashcardGradient
                        )
                    }
                    .padding(.horizontal)
                    
                    // 本周番茄钟趋势
                    if #available(iOS 16.0, *) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("本周番茄钟")
                                .font(Theme.headlineFont)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(weeklyPomodoroData(), id: \.day) { data in
                                    BarMark(
                                        x: .value("日期", data.day),
                                        y: .value("数量", data.count)
                                    )
                                    .foregroundStyle(Theme.pomodoroGradient)
                                    .cornerRadius(4)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(Theme.cornerRadius)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                    
                    // 待办事项统计
                    VStack(alignment: .leading, spacing: 12) {
                        Text("待办事项分布")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            ForEach(TodoItem.Priority.allCases.reversed(), id: \.self) { priority in
                                let count = todos.filter { $0.priority == priority }.count
                                VStack(spacing: 8) {
                                    Text("\(count)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color(hex: priority.colorHex))
                                    
                                    Text(priority.displayName)
                                        .font(Theme.captionFont)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(Theme.smallCornerRadius)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 习惯完成率
                    VStack(alignment: .leading, spacing: 12) {
                        Text("习惯追踪")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        ForEach(habits) { habit in
                            HabitProgressRow(habit: habit)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("数据统计")
        }
    }
    
    // MARK: - 计算属性
    private var todayPomodoroCount: Int {
        pomodoroSessions.filter { session in
            session.sessionType == .work &&
            session.isCompleted &&
            session.startTime.isToday
        }.count
    }
    
    private var todoCompletionRate: Int {
        let total = todos.count
        guard total > 0 else { return 0 }
        let completed = todos.filter { $0.isCompleted }.count
        return Int(Double(completed) / Double(total) * 100)
    }
    
    private var habitsCheckedToday: Int {
        habits.filter { habit in
            habit.records.contains { record in
                record.date.isToday
            }
        }.count
    }
    
    private var upcomingEventsCount: Int {
        events.filter { event in
            event.startDate > Date() &&
            event.startDate < Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        }.count
    }
    
    private var weeklyStudyHours: Int {
        let sessions = pomodoroSessions.filter {
            $0.sessionType == .work && $0.isCompleted && $0.startTime.isThisWeek
        }
        return sessions.count * 25 / 60
    }
    
    private func weeklyPomodoroData() -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: -6 + i, to: Date())!
            let dayName = date.formatted("E")
            let count = pomodoroSessions.filter { session in
                session.sessionType == .work &&
                session.isCompleted &&
                calendar.isDate(session.startTime, inSameDayAs: date)
            }.count
            return (dayName, count)
        }
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
    }
}

struct HabitProgressRow: View {
    let habit: Habit
    
    private var progressPercentage: Double {
        let last7Days = (0..<7).map { i in
            Calendar.current.date(byAdding: .day, value: -i, to: Date())!
        }
        
        let completedDays = last7Days.filter { date in
            habit.records.contains { record in
                Calendar.current.isDate(record.date, inSameDayAs: date)
            }
        }.count
        
        return Double(completedDays) / 7.0 * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: habit.icon)
                    .foregroundColor(Color(hex: habit.colorHex))
                
                Text(habit.name)
                    .font(Theme.bodyFont)
                
                Spacer()
                
                Text("\(Int(progressPercentage))%")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: habit.colorHex))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: habit.colorHex))
                        .frame(width: geometry.size.width * progressPercentage / 100)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.smallCornerRadius)
        .padding(.horizontal)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [
            PomodoroSession.self,
            TodoItem.self,
            Habit.self,
            CalendarEvent.self
        ], inMemory: true)
}

