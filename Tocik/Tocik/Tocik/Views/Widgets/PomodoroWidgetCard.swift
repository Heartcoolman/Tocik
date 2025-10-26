//
//  PomodoroWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 番茄钟小部件卡片
//

import SwiftUI
import SwiftData

struct PomodoroWidgetCard: View {
    @Query private var sessions: [PomodoroSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(Theme.pomodoroGradient)
                Text("番茄钟")
                    .font(.headline)
                
                Spacer()
                
                Text("今日")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 数据
            HStack(alignment: .bottom, spacing: 16) {
                // 今日数量
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(todayCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.pomodoroGradient)
                    
                    Text("个完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 迷你圆环
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: min(Double(todayCount) / 8.0, 1.0))
                        .stroke(Theme.pomodoroGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var todayCount: Int {
        sessions.filter {
            Calendar.current.isDateInToday($0.startTime) && $0.isCompleted
        }.count
    }
}

