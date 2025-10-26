//
//  HabitWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 习惯小部件卡片
//

import SwiftUI
import SwiftData

struct HabitWidgetCard: View {
    @Query private var habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "star")
                    .foregroundStyle(Theme.habitGradient)
                Text("习惯打卡")
                    .font(.headline)
                
                Spacer()
                
                Text("今日")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 数据
            HStack(spacing: 16) {
                // 今日打卡数
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(todayCheckedCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.habitGradient)
                    
                    Text("已打卡")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 最长连续
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(maxStreak)")
                            .font(.title2.bold())
                    }
                    
                    Text("最长连续")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var todayCheckedCount: Int {
        habits.reduce(0) { total, habit in
            total + habit.records.filter { Calendar.current.isDateInToday($0.date) }.count
        }
    }
    
    private var maxStreak: Int {
        habits.map { $0.getCurrentStreak() }.max() ?? 0
    }
}

