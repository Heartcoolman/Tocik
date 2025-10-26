//
//  AnalysisHistoryTab.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  分析历史标签页
//

import SwiftUI
import SwiftData

struct AnalysisHistoryTab: View {
    @Query(sort: \UserProfile.lastAIAnalysisDate, order: .reverse) private var userProfiles: [UserProfile]
    
    @State private var mockRecords: [AnalysisRecord] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 统计概览卡片
                if let profile = userProfiles.first {
                    HistoryStatsCard(profile: profile)
                }
                
                // 趋势图表
                if !mockRecords.isEmpty {
                    UsageTrendCard(records: mockRecords)
                }
                
                // 历史记录时间线
                if !mockRecords.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                        Text("分析历史")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        AnalysisHistoryTimeline(records: mockRecords)
                            .padding(.horizontal)
                    }
                } else {
                    EmptyHistoryView()
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            generateMockRecords()
        }
    }
    
    private func generateMockRecords() {
        mockRecords = [
            AnalysisRecord(
                date: Date(),
                type: .hybrid,
                tokensUsed: 1250,
                suggestionsCount: 5,
                weaknessCount: 2,
                anomalyCount: 1,
                summary: "检测到学习效率下降，建议调整作息时间"
            ),
            AnalysisRecord(
                date: Date().addingTimeInterval(-86400),
                type: .local,
                tokensUsed: 0,
                suggestionsCount: 3,
                weaknessCount: 1,
                anomalyCount: 0,
                summary: "数据量不足，仅进行本地分析"
            ),
            AnalysisRecord(
                date: Date().addingTimeInterval(-172800),
                type: .ai,
                tokensUsed: 2100,
                suggestionsCount: 7,
                weaknessCount: 3,
                anomalyCount: 2,
                summary: "全面AI分析，识别多个学习模式"
            ),
            AnalysisRecord(
                date: Date().addingTimeInterval(-259200),
                type: .hybrid,
                tokensUsed: 1800,
                suggestionsCount: 6,
                weaknessCount: 2,
                anomalyCount: 1,
                summary: "混合分析，发现时间管理问题"
            )
        ]
    }
}

// 历史统计卡片
struct HistoryStatsCard: View {
    let profile: UserProfile
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("使用统计")
                .font(.title3.bold())
            
            LazyVGrid(columns: columns, spacing: 12) {
                HistoryStatItem(
                    icon: "chart.bar.fill",
                    value: "\(profile.totalAIAnalysisCalls)",
                    label: "总分析次数",
                    gradient: Theme.statsGradient
                )
                
                HistoryStatItem(
                    icon: "sparkles",
                    value: "\(profile.totalSuggestionsReceived)",
                    label: "收到建议",
                    gradient: Theme.primaryGradient
                )
                
                HistoryStatItem(
                    icon: "checkmark.circle.fill",
                    value: String(format: "%.0f%%", profile.acceptanceRate * 100),
                    label: "接受率",
                    gradient: Theme.habitGradient
                )
                
                HistoryStatItem(
                    icon: "cpu",
                    value: "\(profile.totalTokensUsed)",
                    label: "Token消耗",
                    gradient: Theme.todoGradient
                )
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }
}

struct HistoryStatItem: View {
    let icon: String
    let value: String
    let label: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(gradient)
            
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(gradient)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 使用趋势卡片
struct UsageTrendCard: View {
    let records: [AnalysisRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("使用趋势")
                .font(.title3.bold())
            
            // Token消耗趋势
            if !tokenTrendData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Token消耗趋势")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                    
                    TrendChartView(
                        historicalData: tokenTrendData,
                        predictedData: [],
                        title: "",
                        gradient: Theme.primaryGradient
                    )
                }
            }
            
            // 分析频率
            HStack(spacing: 16) {
                TrendStatBadge(
                    icon: "calendar",
                    title: "平均间隔",
                    value: "\(averageInterval)天",
                    color: .blue
                )
                
                TrendStatBadge(
                    icon: "clock",
                    title: "最近分析",
                    value: lastAnalysisText,
                    color: .green
                )
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }
    
    private var tokenTrendData: [DateValue] {
        records.reversed().map { record in
            DateValue(date: record.date, value: Double(record.tokensUsed))
        }
    }
    
    private var averageInterval: Int {
        guard records.count >= 2 else { return 0 }
        let sortedRecords = records.sorted { $0.date < $1.date }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedRecords.count {
            let interval = sortedRecords[i].date.timeIntervalSince(sortedRecords[i-1].date)
            intervals.append(interval)
        }
        
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        return Int(avgInterval / 86400) // 转换为天数
    }
    
    private var lastAnalysisText: String {
        guard let latest = records.first else { return "-" }
        let days = Calendar.current.dateComponents([.day], from: latest.date, to: Date()).day ?? 0
        if days == 0 {
            return "今天"
        } else if days == 1 {
            return "昨天"
        } else {
            return "\(days)天前"
        }
    }
}

struct TrendStatBadge: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.bold())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 空历史视图
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Theme.primaryGradient)
            
            Text("暂无分析历史")
                .font(.title2.bold())
            
            Text("开始您的第一次AI分析\n建立学习洞察历史记录")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - 数据模型

/// 日期-值数据模型，用于趋势图表
struct DateValue: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

#Preview {
    NavigationStack {
        AnalysisHistoryTab()
    }
}

