//
//  PersonalGrowthView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 个人成长报告
//

import SwiftUI
import SwiftData
import Charts

struct PersonalGrowthView: View {
    @Query private var reports: [PersonalReport]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var goals: [Goal]
    @Environment(\.modelContext) private var context
    
    @State private var selectedPeriod: ReportPeriod = .month
    @State private var showGenerateReport = false
    @State private var isGenerating = false
    
    enum ReportPeriod: String, CaseIterable {
        case week = "周"
        case month = "月"
        case quarter = "季度"
        case year = "年"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.xlarge) {
                    // 成长概览
                    GrowthOverviewCard(
                        level: calculateLevel(),
                        streak: calculateStreak(),
                        achievements: calculateAchievements()
                    )
                    
                    // 报告列表
                    if !reports.isEmpty {
                        ReportHistorySection(reports: reports)
                    }
                    
                    // 强弱项分析
                    StrengthWeaknessSection(
                        pomodoroSessions: pomodoroSessions,
                        todos: todos,
                        habits: habits
                    )
                    
                    // 时间投资回报
                    TimeInvestmentSection(
                        pomodoroSessions: pomodoroSessions,
                        todos: todos
                    )
                    
                    // 目标达成趋势
                    GoalProgressSection(goals: goals)
                    
                    // 生成报告按钮
                    Button(action: generateReport) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "doc.text.fill")
                                Text("生成\(selectedPeriod.rawValue)报")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isGenerating)
                }
                .padding()
            }
            .navigationTitle("个人成长")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("周期", selection: $selectedPeriod) {
                        ForEach(ReportPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
    
    private func calculateLevel() -> Int {
        // 基于总完成数计算等级
        let totalPomodoros = pomodoroSessions.filter { $0.isCompleted }.count
        let totalTodos = todos.filter { $0.isCompleted }.count
        return (totalPomodoros + totalTodos) / 10 + 1
    }
    
    private func calculateStreak() -> Int {
        habits.map { $0.getCurrentStreak() }.max() ?? 0
    }
    
    private func calculateAchievements() -> Int {
        // 这里应该查询Achievement，简化处理
        return 0
    }
    
    private func generateReport() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 计算日期范围
            let (startDate, endDate) = calculateDateRange()
            
            // 生成报告
            let report = PersonalReport(
                reportType: reportType,
                startDate: startDate,
                endDate: endDate
            )
            
            // 分析数据
            analyzeAndFillReport(report: report)
            
            DispatchQueue.main.async {
                context.insert(report)
                isGenerating = false
                HapticManager.shared.success()
            }
        }
    }
    
    private var reportType: PersonalReport.ReportType {
        switch selectedPeriod {
        case .week: return .weekly
        case .month: return .monthly
        case .quarter: return .quarterly
        case .year: return .yearly
        }
    }
    
    private func calculateDateRange() -> (Date, Date) {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .week:
            let start = now.startOfWeek
            return (start, now)
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return (start, now)
        case .quarter:
            let month = calendar.component(.month, from: now)
            let quarterStart = ((month - 1) / 3) * 3 + 1
            var components = calendar.dateComponents([.year], from: now)
            components.month = quarterStart
            let start = calendar.date(from: components)!
            return (start, now)
        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return (start, now)
        }
    }
    
    private func analyzeAndFillReport(report: PersonalReport) {
        let (startDate, endDate) = (report.startDate, report.endDate)
        
        // 筛选数据
        let periodSessions = pomodoroSessions.filter { $0.startTime >= startDate && $0.startTime <= endDate }
        let periodTodos = todos.filter {
            ($0.completedDate ?? Date.distantPast) >= startDate && ($0.completedDate ?? Date.distantPast) <= endDate
        }
        
        // 分析强项
        var strengths: [String] = []
        if periodSessions.count >= 20 {
            strengths.append("学习时间充足，完成了\(periodSessions.count)个番茄钟")
        }
        if periodTodos.count >= 15 {
            strengths.append("执行力强，完成了\(periodTodos.count)个任务")
        }
        report.strengths = strengths.joined(separator: "\n")
        
        // 分析弱项
        var weaknesses: [String] = []
        if periodSessions.count < 10 {
            weaknesses.append("学习时间不足，建议增加学习时长")
        }
        if periodTodos.filter({ !$0.isCompleted }).count > 10 {
            weaknesses.append("未完成任务较多，需要更好的时间管理")
        }
        report.weaknesses = weaknesses.joined(separator: "\n")
        
        // 建议
        var suggestions: [String] = []
        if periodSessions.count < 20 {
            suggestions.append("建议每天至少完成3个番茄钟")
        }
        suggestions.append("继续保持学习节奏，养成良好习惯")
        report.suggestions = suggestions.joined(separator: "\n")
    }
}

// MARK: - 子视图

struct GrowthOverviewCard: View {
    let level: Int
    let streak: Int
    let achievements: Int
    
    var body: some View {
        HStack(spacing: Theme.spacing.xlarge) {
            GrowthStatItem(title: "等级", value: "Lv\(level)", icon: "star.fill", gradient: Theme.primaryGradient)
            GrowthStatItem(title: "最长连续", value: "\(streak)天", icon: "flame.fill", gradient: Theme.habitGradient)
            GrowthStatItem(title: "成就", value: "\(achievements)", icon: "trophy.fill", gradient: Theme.goalGradient)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct GrowthStatItem: View {
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
                .font(.title3.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReportHistorySection: View {
    let reports: [PersonalReport]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("历史报告")
                .font(Theme.titleFont)
            
            ForEach(reports.sorted { $0.generatedDate > $1.generatedDate }.prefix(5)) { report in
                NavigationLink {
                    ReportDetailView(report: report)
                } label: {
                    ReportRow(report: report)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct ReportRow: View {
    let report: PersonalReport
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(report.title)
                    .font(.headline)
                
                Text(formatDate(report.generatedDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct StrengthWeaknessSection: View {
    let pomodoroSessions: [PomodoroSession]
    let todos: [TodoItem]
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("强弱项分析")
                .font(Theme.titleFont)
            
            // 使用智能分析
            if let pattern = analyzePattern() {
                VStack(spacing: 16) {
                    // 强项
                    AnalysisCard(
                        title: "💪 您的优势",
                        items: pattern.strengths,
                        color: .green
                    )
                    
                    // 弱项
                    AnalysisCard(
                        title: "📊 待提升",
                        items: pattern.weaknesses,
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func analyzePattern() -> (strengths: [String], weaknesses: [String])? {
        var strengths: [String] = []
        var weaknesses: [String] = []
        
        // 分析番茄钟
        let monthlyPomodoros = pomodoroSessions.filter {
            $0.startTime >= Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        }.count
        
        if monthlyPomodoros >= 60 {
            strengths.append("学习时间充足")
        } else if monthlyPomodoros < 20 {
            weaknesses.append("学习时间需要增加")
        }
        
        // 分析任务完成
        let completionRate = todos.isEmpty ? 0 : Double(todos.filter { $0.isCompleted }.count) / Double(todos.count)
        if completionRate >= 0.7 {
            strengths.append("任务完成率高")
        } else if completionRate < 0.5 {
            weaknesses.append("任务完成率需提高")
        }
        
        // 分析习惯
        let avgStreak = habits.isEmpty ? 0 : habits.map { $0.getCurrentStreak() }.reduce(0, +) / habits.count
        if avgStreak >= 14 {
            strengths.append("习惯养成坚持得好")
        } else if avgStreak < 7 {
            weaknesses.append("习惯坚持需要加强")
        }
        
        return (strengths, weaknesses)
    }
}

struct AnalysisCard: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            if items.isEmpty {
                Text("继续努力")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(color)
                            
                            Text(item)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TimeInvestmentSection: View {
    let pomodoroSessions: [PomodoroSession]
    let todos: [TodoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("时间投资回报")
                .font(Theme.titleFont)
            
            VStack(spacing: 16) {
                // 时间投入
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("总投入时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(totalHours)小时")
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.primaryGradient)
                }
                
                Divider()
                
                // 产出
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("完成任务数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(completedTasks)")
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.todoGradient)
                }
                
                Divider()
                
                // 效率
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("平均效率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", efficiency))任务/小时")
                            .font(.title3.bold())
                            .foregroundColor(efficiencyColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: efficiencyIcon)
                        .font(.largeTitle)
                        .foregroundColor(efficiencyColor)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var totalHours: Int {
        pomodoroSessions.reduce(0) { $0 + $1.actualDuration } / 60
    }
    
    private var completedTasks: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    private var efficiency: Double {
        guard totalHours > 0 else { return 0 }
        return Double(completedTasks) / Double(totalHours)
    }
    
    private var efficiencyColor: Color {
        if efficiency >= 2.0 { return .green }
        if efficiency >= 1.0 { return .orange }
        return .red
    }
    
    private var efficiencyIcon: String {
        if efficiency >= 2.0 { return "arrow.up.circle.fill" }
        if efficiency >= 1.0 { return "arrow.right.circle.fill" }
        return "arrow.down.circle.fill"
    }
}

struct GoalProgressSection: View {
    let goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("目标达成趋势")
                .font(Theme.titleFont)
            
            if goals.isEmpty {
                Text("还没有设定目标")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(goals.filter { !$0.isArchived }.prefix(5)) { goal in
                        GoalProgressRow(goal: goal)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct GoalProgressRow: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.subheadline.bold())
                
                Spacer()
                
                Text("\(Int(goal.overallProgress()))%")
                    .font(.caption.bold())
                    .foregroundColor(Color(hex: goal.colorHex))
            }
            
            ProgressView(value: goal.overallProgress() / 100.0)
                .tint(Color(hex: goal.colorHex))
        }
        .padding()
        .background(Color(hex: goal.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ReportDetailView: View {
    let report: PersonalReport
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing.xlarge) {
                // 报告标题
                VStack(alignment: .leading, spacing: 8) {
                    Text(report.title)
                        .font(.largeTitle.bold())
                    
                    Text(formatDateRange(report.startDate, report.endDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 强项
                if !report.strengths.isEmpty {
                    ReportSection(title: "💪 优势", content: report.strengths, color: .green)
                }
                
                // 弱项
                if !report.weaknesses.isEmpty {
                    ReportSection(title: "📊 待提升", content: report.weaknesses, color: .orange)
                }
                
                // 建议
                if !report.suggestions.isEmpty {
                    ReportSection(title: "💡 建议", content: report.suggestions, color: .blue)
                }
                
                // 成就总结
                if !report.achievementsSummary.isEmpty {
                    ReportSection(title: "🏆 成就", content: report.achievementsSummary, color: .yellow)
                }
            }
            .padding()
        }
        .navigationTitle("报告详情")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareReportDetailView(report: report)
        }
    }
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct ReportSection: View {
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ShareReportDetailView: View {
    let report: PersonalReport
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(reportText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("分享报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: reportText) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var reportText: String {
        """
        📊 \(report.title)
        
        📅 \(formatDate(report.startDate)) - \(formatDate(report.endDate))
        
        💪 优势:
        \(report.strengths)
        
        📊 待提升:
        \(report.weaknesses)
        
        💡 建议:
        \(report.suggestions)
        
        🏆 成就:
        \(report.achievementsSummary.isEmpty ? "继续努力" : report.achievementsSummary)
        
        ---
        由 Tocik v4.0 生成
        """
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

