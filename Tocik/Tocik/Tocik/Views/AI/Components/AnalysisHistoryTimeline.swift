//
//  AnalysisHistoryTimeline.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  分析历史时间线组件
//

import SwiftUI

struct AnalysisHistoryTimeline: View {
    let records: [AnalysisRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                VStack(alignment: .leading, spacing: 12) {
                    // 日期标题
                    Text(formatDate(date))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                    
                    // 该日期的记录
                    ForEach(groupedRecords[date] ?? []) { record in
                        HistoryRecordCard(record: record)
                    }
                }
            }
        }
    }
    
    private var groupedRecords: [Date: [AnalysisRecord]] {
        Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return formatter.string(from: date)
        }
    }
}

struct HistoryRecordCard: View {
    let record: AnalysisRecord
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 时间轴圆点
                ZStack {
                    Circle()
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: typeIcon)
                        .foregroundColor(typeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(record.type.displayName)
                            .font(.subheadline.bold())
                        
                        Text(formatTime(record.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if record.tokensUsed > 0 {
                        Text("消耗 \(record.tokensUsed) tokens")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            // 展开的详细内容
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    if let summary = record.summary {
                        Text(summary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        StatBadge(label: "建议数", value: "\(record.suggestionsCount)")
                        if record.weaknessCount > 0 {
                            StatBadge(label: "弱点", value: "\(record.weaknessCount)")
                        }
                        if record.anomalyCount > 0 {
                            StatBadge(label: "异常", value: "\(record.anomalyCount)")
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(typeColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var typeColor: Color {
        switch record.type {
        case .local: return .blue
        case .ai: return .purple
        case .hybrid: return .green
        }
    }
    
    private var typeIcon: String {
        switch record.type {
        case .local: return "cpu"
        case .ai: return "brain.head.profile"
        case .hybrid: return "sparkles"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption.bold())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// 分析记录数据结构
struct AnalysisRecord: Identifiable {
    let id = UUID()
    let date: Date
    let type: AnalysisType
    let tokensUsed: Int
    let suggestionsCount: Int
    let weaknessCount: Int
    let anomalyCount: Int
    let summary: String?
    
    enum AnalysisType {
        case local, ai, hybrid
        
        var displayName: String {
            switch self {
            case .local: return "本地分析"
            case .ai: return "AI分析"
            case .hybrid: return "混合分析"
            }
        }
    }
}

#Preview {
    ScrollView {
        AnalysisHistoryTimeline(records: [
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
            )
        ])
        .padding()
    }
}

