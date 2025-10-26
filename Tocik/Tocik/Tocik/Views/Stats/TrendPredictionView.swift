//
//  TrendPredictionView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 趋势预测视图
//

import SwiftUI
import SwiftData

struct TrendPredictionView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    
    @State private var predictionDays: Int = 7
    @State private var historicalData: [DateValue] = []
    @State private var predictedData: [DateValue] = []
    @State private var isCalculating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 预测天数选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("预测未来")
                        .font(Theme.titleFont)
                    
                    Picker("预测天数", selection: $predictionDays) {
                        Text("3天").tag(3)
                        Text("7天").tag(7)
                        Text("14天").tag(14)
                        Text("30天").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: predictionDays) { _, _ in
                        calculatePrediction()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                
                // 番茄钟预测
                if isCalculating {
                    ProgressView("计算中...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    TrendChartView(
                        historicalData: historicalData,
                        predictedData: predictedData,
                        title: "番茄钟完成预测",
                        gradient: Theme.pomodoroGradient
                    )
                }
                
                // 预测摘要
                PredictionSummaryCard(
                    historicalAverage: historicalAverage,
                    predictedAverage: predictedAverage,
                    trend: trend
                )
                
                // 目标完成预测
                GoalCompletionPredictions()
                
                // 习惯坚持预测
                HabitContinuancePredictions(habits: habits)
                
                // 建议
                PredictionRecommendations(trend: trend)
            }
            .padding()
        }
        .navigationTitle("趋势预测")
        .onAppear {
            calculatePrediction()
        }
    }
    
    private var historicalAverage: Double {
        guard !historicalData.isEmpty else { return 0 }
        return historicalData.map { $0.value }.reduce(0, +) / Double(historicalData.count)
    }
    
    private var predictedAverage: Double {
        guard !predictedData.isEmpty else { return 0 }
        return predictedData.map { $0.value }.reduce(0, +) / Double(predictedData.count)
    }
    
    private var trend: PredictionTrend {
        if predictedAverage > historicalAverage * 1.1 { return .increasing }
        if predictedAverage < historicalAverage * 0.9 { return .decreasing }
        return .stable
    }
    
    private func calculatePrediction() {
        isCalculating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 获取最近30天的历史数据
            let calendar = Calendar.current
            
            var historical: [DateValue] = []
            for day in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
                    let count = pomodoroSessions.filter {
                        calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted
                    }.count
                    historical.insert(DateValue(date: date, value: Double(count)), at: 0)
                }
            }
            
            // 使用EnhancedPrediction预测（支持季节性分析）
            let predicted = EnhancedPrediction.predictWithSeasonality(
                data: historical,
                daysAhead: predictionDays
            )
            
            DispatchQueue.main.async {
                self.historicalData = historical
                self.predictedData = predicted
                self.isCalculating = false
            }
        }
    }
    
    enum PredictionTrend {
        case increasing, stable, decreasing
    }
}

struct PredictionSummaryCard: View {
    let historicalAverage: Double
    let predictedAverage: Double
    let trend: TrendPredictionView.PredictionTrend
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: Theme.spacing.xlarge) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("历史平均")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", historicalAverage))
                        .font(.title2.bold())
                }
                
                Image(systemName: trendIcon)
                    .font(.title)
                    .foregroundColor(trendColor)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("预测平均")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", predictedAverage))
                        .font(.title2.bold())
                        .foregroundColor(trendColor)
                }
            }
            
            Text(trendDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var trendIcon: String {
        switch trend {
        case .increasing: return "arrow.up.right.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        case .decreasing: return "arrow.down.right.circle.fill"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .increasing: return .green
        case .stable: return .orange
        case .decreasing: return .red
        }
    }
    
    private var trendDescription: String {
        switch trend {
        case .increasing:
            return "预测呈上升趋势，保持这种学习节奏！"
        case .stable:
            return "预测保持稳定，可以考虑适当增加学习量"
        case .decreasing:
            return "预测呈下降趋势，需要调整学习计划"
        }
    }
}

struct GoalCompletionPredictions: View {
    @Query private var goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("目标完成预测")
                .font(Theme.titleFont)
            
            if goals.filter({ !$0.isArchived && $0.overallProgress() < 100 }).isEmpty {
                Text("暂无进行中的目标")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(goals.filter { !$0.isArchived && $0.overallProgress() < 100 }.prefix(5)) { goal in
                        GoalPredictionRow(goal: goal)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct GoalPredictionRow: View {
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
            
            if let prediction = goal.predictCompletionDate() {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                    Text("预计完成: \(formatDate(prediction))")
                        .font(.caption)
                    
                    Spacer()
                    
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: goal.endDate).day ?? 0
                    let predictedDays = Calendar.current.dateComponents([.day], from: Date(), to: prediction).day ?? 0
                    
                    if predictedDays > daysLeft {
                        Text("可能延期")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("有望按时完成")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(hex: goal.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct HabitContinuancePredictions: View {
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("习惯坚持预测")
                .font(Theme.titleFont)
            
            if habits.isEmpty {
                Text("暂无习惯")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(habits.prefix(5)) { habit in
                        HabitPredictionRow(habit: habit)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct HabitPredictionRow: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            Image(systemName: habit.icon)
                .foregroundColor(Color(hex: habit.colorHex))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline.bold())
                
                HStack {
                    Text("当前连续: \(habit.getCurrentStreak())天")
                    Text("•")
                    Text("坚持概率: \(Int(continuanceProbability * 100))%")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 概率指示器
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: continuanceProbability)
                    .stroke(probabilityColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding()
        .background(Color(hex: habit.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var continuanceProbability: Double {
        let streak = habit.getCurrentStreak()
        let allStreaks = [streak] // 简化处理，实际应该获取历史连续记录
        return EnhancedPrediction.predictHabitContinuance(
            streakHistory: allStreaks,
            currentStreak: streak
        )
    }
    
    private var probabilityColor: Color {
        if continuanceProbability >= 0.7 { return .green }
        if continuanceProbability >= 0.5 { return .orange }
        return .red
    }
}

struct PredictionRecommendations: View {
    let trend: TrendPredictionView.PredictionTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Label("💡 基于预测的建议", systemImage: "lightbulb.fill")
                .font(Theme.titleFont)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                        
                        Text(recommendation)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var recommendations: [String] {
        switch trend {
        case .increasing:
            return [
                "您的学习趋势很好！保持当前的学习节奏",
                "可以考虑挑战更高的目标",
                "利用这段高效期处理重要任务"
            ]
        case .stable:
            return [
                "学习状态比较稳定",
                "可以尝试调整学习方法以提升效率",
                "设定一些小目标来突破瓶颈"
            ]
        case .decreasing:
            return [
                "学习时间可能会减少，需要提前规划",
                "检查是否有外部因素影响",
                "考虑调整学习目标，避免过度压力",
                "可以适当降低任务量，保证质量"
            ]
        }
    }
}

