//
//  PomodoroModePickerView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 番茄钟模式选择器
//

import SwiftUI

struct PomodoroModePickerView: View {
    @Binding var selectedMode: PomodoroSession.SessionMode
    @Environment(\.dismiss) private var dismiss
    
    let modes: [PomodoroSession.SessionMode] = [.standard, .long, .short]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(modes, id: \.self) { mode in
                    Button(action: {
                        selectedMode = mode
                        HapticManager.shared.selection()
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.rawValue)
                                    .font(.headline)
                                
                                Text("\(mode.duration)分钟工作时长")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.pomodoroGradient)
                                    .font(.title2)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("选择模式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 番茄钟洞察视图
struct PomodoroInsightsView: View {
    let sessions: [PomodoroSession]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 专注度趋势
                VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                    Text("专注度趋势")
                        .font(Theme.titleFont)
                    
                    if sessions.isEmpty {
                        Text("暂无数据")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(recentSessions, id: \.id) { session in
                                VStack(spacing: 4) {
                                    // 柱状图
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(focusScoreColor(session.focusScore))
                                        .frame(width: 30, height: CGFloat(session.focusScore))
                                    
                                    // 日期标签
                                    Text(formatDate(session.startTime))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                
                // 统计卡片
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                    StatCard(
                        title: "平均专注度",
                        value: String(format: "%.0f分", averageFocusScore),
                        icon: "brain.head.profile",
                        gradient: Theme.pomodoroGradient
                    )
                    
                    StatCard(
                        title: "完成率",
                        value: String(format: "%.0f%%", completionRate),
                        icon: "checkmark.circle",
                        gradient: Theme.todoGradient
                    )
                    
                    StatCard(
                        title: "总时长",
                        value: "\(totalHours)小时",
                        icon: "clock",
                        gradient: Theme.calendarGradient
                    )
                    
                    StatCard(
                        title: "中断次数",
                        value: "\(totalInterruptions)次",
                        icon: "exclamationmark.triangle",
                        gradient: LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                // 建议
                if let suggestion = generateSuggestion() {
                    VStack(alignment: .leading, spacing: Theme.spacing.small) {
                        Label("💡 建议", systemImage: "lightbulb.fill")
                            .font(Theme.headlineFont)
                        
                        Text(suggestion)
                            .font(Theme.bodyFont)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
            }
            .padding()
        }
        .navigationTitle("番茄钟洞察")
    }
    
    // 计算属性
    private var recentSessions: [PomodoroSession] {
        Array(sessions.suffix(10))
    }
    
    private var averageFocusScore: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map { $0.focusScore }.reduce(0, +) / Double(sessions.count)
    }
    
    private var completionRate: Double {
        guard !sessions.isEmpty else { return 0 }
        let completed = sessions.filter { $0.isCompleted }.count
        return Double(completed) / Double(sessions.count) * 100
    }
    
    private var totalHours: Int {
        let minutes = sessions.reduce(0) { $0 + $1.actualDuration }
        return minutes / 60
    }
    
    private var totalInterruptions: Int {
        sessions.reduce(0) { $0 + $1.interruptionCount }
    }
    
    // 辅助方法
    private func focusScoreColor(_ score: Double) -> LinearGradient {
        if score >= 80 {
            return LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        } else if score >= 60 {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func generateSuggestion() -> String? {
        if averageFocusScore < 70 {
            return "您的平均专注度偏低，建议减少外界干扰，或尝试更短的番茄钟时长"
        } else if totalInterruptions > sessions.count {
            return "中断次数较多，建议在开始番茄钟前做好准备工作，关闭无关通知"
        } else if completionRate > 90 {
            return "完成率很高！保持这种状态，可以尝试挑战更长的深度工作模式"
        }
        return nil
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: Theme.spacing.small) {
            Image(systemName: icon)
                .font(.title)
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

