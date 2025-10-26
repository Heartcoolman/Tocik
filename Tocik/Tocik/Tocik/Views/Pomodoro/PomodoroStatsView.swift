//
//  PomodoroStatsView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData
import Charts

struct PomodoroStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroSession.startTime, order: .reverse) private var sessions: [PomodoroSession]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 总览卡片
                HStack(spacing: 15) {
                    StatsCard(
                        title: "总计",
                        value: "\(totalSessions)",
                        subtitle: "个番茄钟",
                        color: Theme.pomodoroColor
                    )
                    
                    StatsCard(
                        title: "今天",
                        value: "\(todaySessions)",
                        subtitle: "个番茄钟",
                        color: Theme.primaryColor
                    )
                }
                .padding(.horizontal)
                
                // 本周图表
                VStack(alignment: .leading, spacing: 10) {
                    Text("本周趋势")
                        .font(Theme.headlineFont)
                        .padding(.horizontal)
                    
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(last7Days(), id: \.date) { item in
                                BarMark(
                                    x: .value("日期", item.dayName),
                                    y: .value("数量", item.count)
                                )
                                .foregroundStyle(Theme.pomodoroGradient)
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(Theme.cornerRadius)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
                
                // 最近记录
                VStack(alignment: .leading, spacing: 10) {
                    Text("最近记录")
                        .font(Theme.headlineFont)
                        .padding(.horizontal)
                    
                    ForEach(sessions.prefix(10)) { session in
                        SessionRow(session: session)
                    }
                }
                .padding(.bottom)
            }
            .padding(.vertical)
        }
        .navigationTitle("番茄钟统计")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var totalSessions: Int {
        sessions.filter { $0.sessionType == .work && $0.isCompleted }.count
    }
    
    private var todaySessions: Int {
        sessions.filter { $0.sessionType == .work && $0.isCompleted && $0.startTime.isToday }.count
    }
    
    private func last7Days() -> [(date: Date, dayName: String, count: Int)] {
        let calendar = Calendar.current
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayName = date.formatted("EEE")
            let count = sessions.filter { session in
                session.sessionType == .work && 
                session.isCompleted &&
                calendar.isDate(session.startTime, inSameDayAs: date)
            }.count
            return (date, dayName, count)
        }.reversed()
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
    }
}

struct SessionRow: View {
    let session: PomodoroSession
    
    var body: some View {
        HStack {
            Image(systemName: iconForType(session.sessionType))
                .foregroundColor(colorForType(session.sessionType))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.rawValue)
                    .font(Theme.bodyFont)
                
                Text(session.startTime.formatted("HH:mm"))
                    .font(Theme.captionFont)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(duration(from: session.startTime, to: session.endTime))
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.smallCornerRadius)
        .padding(.horizontal)
    }
    
    private func iconForType(_ type: PomodoroSession.SessionType) -> String {
        switch type {
        case .work: return "timer"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "moon.stars.fill"
        }
    }
    
    private func colorForType(_ type: PomodoroSession.SessionType) -> Color {
        switch type {
        case .work: return Theme.pomodoroColor
        case .shortBreak: return Theme.primaryColor
        case .longBreak: return Theme.secondaryColor
        }
    }
    
    private func duration(from start: Date, to end: Date) -> String {
        let interval = Int(end.timeIntervalSince(start))
        let minutes = interval / 60
        return "\(minutes)分钟"
    }
}

#Preview {
    NavigationStack {
        PomodoroStatsView()
            .modelContainer(for: PomodoroSession.self, inMemory: true)
    }
}

