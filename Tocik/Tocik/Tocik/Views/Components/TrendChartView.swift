//
//  TrendChartView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 趋势图表组件
//

import SwiftUI
import Charts

struct TrendChartView: View {
    let historicalData: [DateValue]
    let predictedData: [DateValue]
    let title: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            // 标题
            HStack {
                Text(title)
                    .font(Theme.titleFont)
                
                Spacer()
                
                HStack(spacing: 12) {
                    LegendItem(color: gradient, label: "实际")
                    LegendItem(color: LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing), label: "预测", isDashed: true)
                }
                .font(.caption)
            }
            
            // 图表
            if #available(iOS 16.0, *) {
                Chart {
                    // 历史数据
                    ForEach(historicalData, id: \.date) { data in
                        LineMark(
                            x: .value("日期", data.date),
                            y: .value("数量", data.value)
                        )
                        .foregroundStyle(gradient)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("日期", data.date),
                            y: .value("数量", data.value)
                        )
                        .foregroundStyle(gradient.opacity(0.2))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    // 预测数据
                    ForEach(predictedData, id: \.date) { data in
                        LineMark(
                            x: .value("日期", data.date),
                            y: .value("数量", data.value)
                        )
                        .foregroundStyle(.gray)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("日期", data.date),
                            y: .value("数量", data.value)
                        )
                        .foregroundStyle(.gray.opacity(0.5))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month().day())
                                    .font(.caption2)
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
            
            // 统计信息
            HStack {
                TrendStat(title: "平均", value: String(format: "%.1f", averageValue))
                TrendStat(title: "最高", value: String(format: "%.0f", maxValue))
                TrendStat(title: "增长", value: growthText, color: growthColor)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var averageValue: Double {
        guard !historicalData.isEmpty else { return 0 }
        return historicalData.map { $0.value }.reduce(0, +) / Double(historicalData.count)
    }
    
    private var maxValue: Double {
        historicalData.map { $0.value }.max() ?? 0
    }
    
    private var growthText: String {
        guard historicalData.count >= 2 else { return "-" }
        let recent = historicalData.suffix(3).map { $0.value }.reduce(0, +) / 3.0
        let previous = historicalData.prefix(historicalData.count - 3).suffix(3).map { $0.value }.reduce(0, +) / 3.0
        
        guard previous > 0 else { return "-" }
        let growth = (recent - previous) / previous * 100
        return String(format: "%+.0f%%", growth)
    }
    
    private var growthColor: Color {
        guard historicalData.count >= 2 else { return .gray }
        let recent = historicalData.suffix(3).map { $0.value }.reduce(0, +)
        let previous = historicalData.prefix(historicalData.count - 3).suffix(3).map { $0.value }.reduce(0, +)
        
        if recent > previous { return .green }
        if recent < previous { return .red }
        return .gray
    }
}

struct LegendItem: View {
    let color: LinearGradient
    let label: String
    var isDashed: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            if isDashed {
                Rectangle()
                    .fill(.gray)
                    .frame(width: 16, height: 2)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 16, height: 3)
            }
            
            Text(label)
        }
    }
}

struct TrendStat: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

