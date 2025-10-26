//
//  HeatMapView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 热力图组件（GitHub风格）
//

import SwiftUI

struct HeatMapView: View {
    let data: [DateValue]  // 日期和对应的值
    let maxValue: Double
    let colorGradient: [Color]
    
    private let columns = 53  // 一年约52周
    private let cellSize: CGFloat = 12
    private let spacing: CGFloat = 2
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("活动热力图")
                .font(Theme.headlineFont)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: spacing) {
                    // 星期标签
                    HStack(spacing: spacing) {
                        Text("")
                            .frame(width: 20)
                        
                        ForEach(0..<columns, id: \.self) { _ in
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                    
                    // 7行（星期一到星期日）
                    ForEach(0..<7) { row in
                        HStack(spacing: spacing) {
                            // 星期标签
                            Text(weekdayLabel(row))
                                .font(.caption2)
                                .frame(width: 20)
                                .foregroundColor(.secondary)
                            
                            ForEach(0..<columns, id: \.self) { col in
                                cellView(row: row, col: col)
                            }
                        }
                    }
                }
                .padding()
            }
            
            // 图例
            HStack {
                Text("少")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForLevel(level))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Text("多")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func cellView(row: Int, col: Int) -> some View {
        let date = dateForCell(row: row, col: col)
        let value = valueForDate(date)
        let level = levelForValue(value)
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(colorForLevel(level))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }
    
    private func dateForCell(row: Int, col: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let daysAgo = (columns - 1 - col) * 7 + (6 - row)
        return calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
    }
    
    private func valueForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        return data.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }?.value ?? 0
    }
    
    private func levelForValue(_ value: Double) -> Int {
        if value == 0 { return 0 }
        if maxValue == 0 { return 0 }
        
        let percentage = value / maxValue
        if percentage < 0.25 { return 1 }
        if percentage < 0.5 { return 2 }
        if percentage < 0.75 { return 3 }
        return 4
    }
    
    private func colorForLevel(_ level: Int) -> Color {
        if level == 0 {
            return Color.gray.opacity(0.1)
        }
        let index = min(level - 1, colorGradient.count - 1)
        return colorGradient[index]
    }
    
    private func weekdayLabel(_ row: Int) -> String {
        ["一", "二", "三", "四", "五", "六", "日"][row]
    }
}

