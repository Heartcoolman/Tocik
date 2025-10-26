//
//  WeeklyReportView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 周报生成
//

import SwiftUI
import SwiftData
import Charts

struct WeeklyReportView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var flashCards: [FlashCard]
    @Query private var notes: [Note]
    
    @State private var weekOffset: Int = 0
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 周选择器
                WeekSelectorView(weekOffset: $weekOffset)
                
                // 概览卡片
                OverviewSection(
                    pomodoroCount: pomodoroCount,
                    completedTodos: completedTodosCount,
                    studyHours: studyHours,
                    checkedHabits: checkedHabitsCount
                )
                
                // 每日趋势
                DailyTrendChart(data: dailyPomodoroData)
                
                // 科目分布
                SubjectDistributionChart(data: subjectData)
                
                // 习惯完成情况
                HabitCompletionSection(habits: habits, weekStart: weekStart, weekEnd: weekEnd)
                
                // 笔记和闪卡
                LearningActivitiesSection(
                    notesCount: newNotesCount,
                    flashCardsReviewed: flashCardsReviewedCount
                )
                
                // 总结和建议
                SummarySection(
                    performance: performance,
                    suggestions: suggestions
                )
            }
            .padding()
        }
        .navigationTitle("周报")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showShareSheet = true }) {
                    Label("分享", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareReportView(reportData: generateReportData())
        }
    }
    
    // MARK: - 计算属性
    
    private var weekStart: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: Date().startOfWeek) ?? Date()
    }
    
    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? Date()
    }
    
    private var weekSessions: [PomodoroSession] {
        pomodoroSessions.filter { $0.startTime >= weekStart && $0.startTime <= weekEnd }
    }
    
    private var pomodoroCount: Int {
        weekSessions.filter { $0.isCompleted }.count
    }
    
    private var completedTodosCount: Int {
        todos.filter {
            guard let date = $0.completedDate else { return false }
            return date >= weekStart && date <= weekEnd
        }.count
    }
    
    private var studyHours: Int {
        weekSessions.reduce(0) { $0 + $1.actualDuration } / 60
    }
    
    private var checkedHabitsCount: Int {
        habits.reduce(0) { total, habit in
            total + habit.records.filter { $0.date >= weekStart && $0.date <= weekEnd }.count
        }
    }
    
    private var newNotesCount: Int {
        notes.filter { $0.createdDate >= weekStart && $0.createdDate <= weekEnd }.count
    }
    
    private var flashCardsReviewedCount: Int {
        flashCards.filter {
            guard let date = $0.lastReviewDate else { return false }
            return date >= weekStart && date <= weekEnd
        }.count
    }
    
    private var dailyPomodoroData: [DateValue] {
        var data: [DateValue] = []
        for day in 0..<7 {
            if let date = Calendar.current.date(byAdding: .day, value: day, to: weekStart) {
                let count = weekSessions.filter {
                    Calendar.current.isDate($0.startTime, inSameDayAs: date)
                }.count
                data.append(DateValue(date: date, value: Double(count)))
            }
        }
        return data
    }
    
    private var subjectData: [(String, Int)] {
        let completedTodos = todos.filter {
            guard let date = $0.completedDate else { return false }
            return date >= weekStart && date <= weekEnd
        }
        
        let grouped = Dictionary(grouping: completedTodos) { $0.category }
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
    }
    
    private var performance: PerformanceLevel {
        let avgDaily = Double(pomodoroCount) / 7.0
        if avgDaily >= 8 { return .excellent }
        if avgDaily >= 5 { return .good }
        if avgDaily >= 3 { return .fair }
        return .needsImprovement
    }
    
    private var suggestions: [String] {
        var tips: [String] = []
        
        if pomodoroCount < 21 {
            tips.append("本周完成的番茄钟较少，建议增加学习时长")
        }
        
        if completedTodosCount < 7 {
            tips.append("待办完成数量偏低，可以设定更具体的每日目标")
        }
        
        if checkedHabitsCount < habits.count * 5 {
            tips.append("习惯打卡需要加强，坚持才能看到效果")
        }
        
        if tips.isEmpty {
            tips.append("表现很好！继续保持这种学习节奏")
        }
        
        return tips
    }
    
    private func generateReportData() -> String {
        """
        📊 本周学习报告
        
        📅 时间: \(formatDate(weekStart)) - \(formatDate(weekEnd))
        
        ✅ 完成数据:
        - 番茄钟: \(pomodoroCount)个
        - 待办事项: \(completedTodosCount)个
        - 学习时长: \(studyHours)小时
        - 习惯打卡: \(checkedHabitsCount)次
        
        📝 学习活动:
        - 新增笔记: \(newNotesCount)篇
        - 复习闪卡: \(flashCardsReviewedCount)张
        
        💡 表现评价: \(performance.displayName)
        
        🎯 建议:
        \(suggestions.map { "- " + $0 }.joined(separator: "\n"))
        """
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
    
    enum PerformanceLevel {
        case excellent, good, fair, needsImprovement
        
        var displayName: String {
            switch self {
            case .excellent: return "优秀 ⭐️⭐️⭐️⭐️⭐️"
            case .good: return "良好 ⭐️⭐️⭐️⭐️"
            case .fair: return "一般 ⭐️⭐️⭐️"
            case .needsImprovement: return "需改进 ⭐️⭐️"
            }
        }
    }
}

// MARK: - 子视图

struct WeekSelectorView: View {
    @Binding var weekOffset: Int
    
    var body: some View {
        HStack {
            Button(action: { weekOffset -= 1 }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(weekText)
                .font(.headline)
            
            Spacer()
            
            Button(action: { weekOffset += 1 }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(weekOffset >= 0)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var weekText: String {
        let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: Date().startOfWeek) ?? Date()
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        
        if weekOffset == 0 {
            return "本周 (\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd)))"
        } else {
            return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
        }
    }
}

struct OverviewSection: View {
    let pomodoroCount: Int
    let completedTodos: Int
    let studyHours: Int
    let checkedHabits: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
            WeeklyOverviewCard(title: "番茄钟", value: "\(pomodoroCount)", icon: "timer", color: Theme.pomodoroColor)
            WeeklyOverviewCard(title: "待办", value: "\(completedTodos)", icon: "checkmark.circle", color: Theme.todoColor)
            WeeklyOverviewCard(title: "学习时长", value: "\(studyHours)h", icon: "clock", color: Theme.calendarColor)
            WeeklyOverviewCard(title: "习惯打卡", value: "\(checkedHabits)", icon: "star", color: Theme.habitColor)
        }
    }
}

struct WeeklyOverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct DailyTrendChart: View {
    let data: [DateValue]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("每日趋势")
                .font(Theme.titleFont)
            
            if #available(iOS 16.0, *) {
                Chart(data, id: \.date) { item in
                    BarMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("数量", item.value)
                    )
                    .foregroundStyle(Theme.pomodoroGradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.narrow))
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                Text("需要 iOS 16+ 显示图表")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct SubjectDistributionChart: View {
    let data: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("任务分类分布")
                .font(Theme.titleFont)
            
            if data.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(data.prefix(5), id: \.0) { subject, count in
                        HStack {
                            Text(subject)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline.bold())
                            
                            // 进度条
                            let maxCount = data.first?.1 ?? 1
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.todoGradient)
                                    .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount))
                            }
                            .frame(width: 80, height: 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct HabitCompletionSection: View {
    let habits: [Habit]
    let weekStart: Date
    let weekEnd: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("习惯完成情况")
                .font(Theme.titleFont)
            
            if habits.isEmpty {
                Text("暂无习惯")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(habits.prefix(5)) { habit in
                    HabitWeekRow(habit: habit, weekStart: weekStart, weekEnd: weekEnd)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct HabitWeekRow: View {
    let habit: Habit
    let weekStart: Date
    let weekEnd: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name)
                .font(.subheadline.bold())
            
            HStack(spacing: 4) {
                ForEach(0..<7) { day in
                    let date = Calendar.current.date(byAdding: .day, value: day, to: weekStart) ?? Date()
                    let hasRecord = habit.records.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    
                    Circle()
                        .fill(hasRecord ? Color(hex: habit.colorHex) : Color.gray.opacity(0.2))
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}

struct LearningActivitiesSection: View {
    let notesCount: Int
    let flashCardsReviewed: Int
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            ActivityCard(title: "新增笔记", value: "\(notesCount)", icon: "doc.text", gradient: Theme.primaryGradient)
            ActivityCard(title: "复习闪卡", value: "\(flashCardsReviewed)", icon: "rectangle.stack", gradient: Theme.flashcardGradient)
        }
    }
}

struct ActivityCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(gradient)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct SummarySection: View {
    let performance: WeeklyReportView.PerformanceLevel
    let suggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("总结与建议")
                .font(Theme.titleFont)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("本周表现")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(performance.displayName)
                        .font(.subheadline.bold())
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct ShareReportView: View {
    let reportData: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(reportData)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("分享周报")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: reportData) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// Date扩展
extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}

