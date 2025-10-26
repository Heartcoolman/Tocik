//
//  DataInsightsTab.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  数据洞察标签页
//

import SwiftUI
import SwiftData

struct DataInsightsTab: View {
    let studyPattern: StudyPattern?
    let weaknesses: [KnowledgeWeakness]
    let anomalies: [Anomaly]
    let crossInsights: [CrossDataInsight]
    let pomodoroSessions: [PomodoroSession]
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: Theme.spacing.medium), count: count)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.spacing.large) {
                // 学习模式分析
                if let pattern = studyPattern {
                    StudyPatternAnalysisCard(pattern: pattern, sessions: pomodoroSessions)
                        .gridCellColumns(horizontalSizeClass == .regular ? 2 : 1)
                }
                
                // 知识弱点
                if !weaknesses.isEmpty {
                    WeaknessAnalysisCard(weaknesses: weaknesses)
                }
                
                // 跨数据洞察
                ForEach(crossInsights) { insight in
                    CrossInsightModernCard(insight: insight)
                }
                
                // 异常检测
                ForEach(anomalies) { anomaly in
                    AnomalyModernCard(anomaly: anomaly)
                }
            }
            .padding()
        }
    }
}

// 学习模式分析卡片（带趋势图）
struct StudyPatternAnalysisCard: View {
    let pattern: StudyPattern
    let sessions: [PomodoroSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Label("学习模式分析", systemImage: "chart.line.uptrend.xyaxis")
                .font(.title3.bold())
                .foregroundStyle(Theme.statsGradient)
            
            // 关键指标网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatIndicator(
                    icon: "clock",
                    title: "最佳时段",
                    value: "\(pattern.bestStudyHour):00"
                )
                
                StatIndicator(
                    icon: "brain",
                    title: "平均专注度",
                    value: String(format: "%.0f分", pattern.averageFocusScore)
                )
                
                StatIndicator(
                    icon: "checkmark.circle",
                    title: "完成率",
                    value: String(format: "%.0f%%", pattern.taskCompletionRate * 100)
                )
                
                StatIndicator(
                    icon: "flame",
                    title: "连续天数",
                    value: String(format: "%.0f天", pattern.averageStreak)
                )
            }
            
            // 7天趋势图
            if !last7DaysData.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                TrendChartView(
                    historicalData: last7DaysData,
                    predictedData: [],
                    title: "7天番茄钟趋势",
                    gradient: Theme.pomodoroGradient
                )
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var last7DaysData: [DateValue] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var data: [DateValue] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -6 + i, to: today) else { continue }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: date)!
            let count = sessions.filter { $0.startTime >= date && $0.startTime < nextDay }.count
            data.append(DateValue(date: date, value: Double(count)))
        }
        
        return data
    }
}

struct StatIndicator: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.primaryGradient)
            
            Text(value)
                .font(.title3.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 知识弱点分析卡片
struct WeaknessAnalysisCard: View {
    let weaknesses: [KnowledgeWeakness]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Label("需要加强的领域", systemImage: "exclamationmark.triangle.fill")
                .font(.title3.bold())
                .foregroundColor(.orange)
            
            ForEach(Array(weaknesses.prefix(5).enumerated()), id: \.offset) { index, weakness in
                WeaknessRow(weakness: weakness, rank: index + 1)
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
}

struct WeaknessRow: View {
    let weakness: KnowledgeWeakness
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // 排名
            Text("\(rank)")
                .font(.title2.bold())
                .foregroundColor(Color(hex: weakness.severity.colorHex))
                .frame(width: 35)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(weakness.subject)
                        .font(.subheadline.bold())
                    
                    Text(weakness.severity.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: weakness.severity.colorHex).opacity(0.2))
                        .foregroundColor(Color(hex: weakness.severity.colorHex))
                        .clipShape(Capsule())
                }
                
                Text("\(weakness.itemCount)个\(weakness.weaknessType.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 严重程度指示器
            ProgressView(value: Double(weakness.severity.rawValue), total: 3.0)
                .tint(Color(hex: weakness.severity.colorHex))
                .frame(width: 60)
        }
        .padding(.vertical, 8)
    }
}

// 现代化跨数据洞察卡片
struct CrossInsightModernCard: View {
    let insight: CrossDataInsight
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                // 优先级环
                ZStack {
                    Circle()
                        .stroke(priorityColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: priorityProgress)
                        .stroke(priorityColor, lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text(insight.category.icon)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.subheadline.bold())
                    
                    Text(insight.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(priorityColor)
                }
            }
            
            if isExpanded {
                Divider()
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !insight.suggestion.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(insight.suggestion)
                            .font(.caption)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(priorityColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
    
    private var priorityProgress: Double {
        switch insight.priority {
        case .urgent: return 1.0
        case .high: return 0.75
        case .medium: return 0.5
        case .low: return 0.25
        }
    }
}

extension CrossDataInsight.InsightCategory {
    var icon: String {
        switch self {
        case .examPreparation: return "📝"
        case .timeManagement: return "⏰"
        case .subjectWeakness: return "📚"
        case .focusImprovement: return "⭐️"
        case .timeConflict: return "🔄"
        case .knowledgeManagement: return "📖"
        case .studyMethod: return "🎯"
        case .planExecution: return "✅"
        }
    }
}

// 现代化异常卡片
struct AnomalyModernCard: View {
    let anomaly: Anomaly
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Image(systemName: anomaly.severity.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: anomaly.severity.colorHex))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(anomaly.title)
                        .font(.subheadline.bold())
                    
                    Text(anomaly.severity.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: anomaly.severity.colorHex).opacity(0.2))
                        .foregroundColor(Color(hex: anomaly.severity.colorHex))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            Text(anomaly.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 严重程度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: anomaly.severity.colorHex), Color(hex: anomaly.severity.colorHex).opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * severityProgress, height: 8)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 8)
            
            Divider()
            
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(anomaly.recommendation)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(Theme.spacing.large)
        .background(Color(hex: anomaly.severity.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(Color(hex: anomaly.severity.colorHex).opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var severityProgress: Double {
        switch anomaly.severity {
        case .low: return 0.33
        case .medium: return 0.66
        case .high: return 1.0
        }
    }
}

#Preview {
    DataInsightsTab(
        studyPattern: StudyPattern(
            bestStudyHour: 9,
            averageFocusScore: 85,
            taskCompletionRate: 0.75,
            averageStreak: 7,
            totalPomodoroCount: 45,
            analysisDate: Date()
        ),
        weaknesses: [
            KnowledgeWeakness(
                subject: "数学",
                weaknessType: .wrongQuestions,
                severity: .high,
                itemCount: 8,
                averageScore: 45
            )
        ],
        anomalies: [
            Anomaly(
                type: .productivityDecrease,
                severity: .medium,
                title: "学习时长异常下降",
                description: "过去3天的学习时长比平均值下降了40%",
                recommendation: "建议恢复正常学习计划"
            )
        ],
        crossInsights: [
            CrossDataInsight(
                title: "物理考试临近但复习不足",
                description: "距离物理考试还有5天，但本周仅学习2小时",
                suggestion: "建议每天安排3个番茄钟用于物理复习",
                priority: .urgent,
                category: .examPreparation,
                relatedData: ["exam": "物理", "pomodoro": 3]
            )
        ],
        pomodoroSessions: []
    )
}

