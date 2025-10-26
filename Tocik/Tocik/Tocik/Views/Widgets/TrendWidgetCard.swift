//
//  TrendWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 趋势小部件卡片
//

import SwiftUI
import SwiftData

struct TrendWidgetCard: View {
    @Query private var sessions: [PomodoroSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundColor(.blue)
                Text("趋势")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trendIcon)
                        .font(.caption)
                    Text(trendText)
                        .font(.caption.bold())
                }
                .foregroundColor(trendColor)
            }
            
            // 迷你折线图
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(last7DaysCounts, id: \.0) { day, count in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.pomodoroGradient)
                            .frame(width: 20, height: CGFloat(count) * 8 + 10)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var last7DaysCounts: [(Int, Int)] {
        let calendar = Calendar.current
        return (0..<7).map { day in
            let date = calendar.date(byAdding: .day, value: -6 + day, to: Date())!
            let count = sessions.filter {
                calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted
            }.count
            return (day, count)
        }
    }
    
    private var trendIcon: String {
        let counts = last7DaysCounts.map { $0.1 }
        if counts.last ?? 0 > counts.first ?? 0 { return "arrow.up.right" }
        if counts.last ?? 0 < counts.first ?? 0 { return "arrow.down.right" }
        return "arrow.right"
    }
    
    private var trendColor: Color {
        let counts = last7DaysCounts.map { $0.1 }
        if counts.last ?? 0 > counts.first ?? 0 { return .green }
        if counts.last ?? 0 < counts.first ?? 0 { return .red }
        return .orange
    }
    
    private var trendText: String {
        let counts = last7DaysCounts.map { $0.1 }
        if counts.last ?? 0 > counts.first ?? 0 { return "上升" }
        if counts.last ?? 0 < counts.first ?? 0 { return "下降" }
        return "稳定"
    }
}

