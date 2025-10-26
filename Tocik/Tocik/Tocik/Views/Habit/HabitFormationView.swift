//
//  HabitFormationView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 习惯形成进度
//

import SwiftUI

struct HabitFormationView: View {
    @Bindable var habit: Habit
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 习惯形成进度环
                FormationProgressRing(habit: habit)
                
                // 里程碑
                MilestonesSection(
                    currentStreak: habit.getCurrentStreak(),
                    target: habit.formationTarget
                )
                
                // 统计数据
                HabitStatsSection(habit: habit)
                
                // 习惯评分
                HabitScoreSection(habit: habit)
                
                // 打卡日历
                CheckInCalendarSection(habit: habit)
                
                // 动机笔记
                MotivationSection(habit: habit)
            }
            .padding()
        }
        .navigationTitle("习惯形成")
    }
}

struct FormationProgressRing: View {
    let habit: Habit
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            ZStack {
                // 外圈：目标进度
                ProgressRingView(
                    progress: habit.formationProgress(),
                    gradient: LinearGradient(
                        colors: [Color(hex: habit.colorHex), Color(hex: habit.colorHex).opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 24,
                    size: 220
                )
                
                VStack(spacing: 8) {
                    Text("\(habit.getCurrentStreak())")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(hex: habit.colorHex), Color(hex: habit.colorHex).opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    
                    Text("天")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("目标: \(habit.formationTarget)天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度说明
            HStack {
                VStack(alignment: .leading) {
                    Text("当前连续")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(habit.getCurrentStreak())天")
                        .font(.headline.bold())
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("完成进度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(habit.formationProgress() * 100))%")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: habit.colorHex))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.heroCornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}

struct MilestonesSection: View {
    let currentStreak: Int
    let target: Int
    
    let milestones = [7, 21, 66, 100]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("里程碑")
                .font(Theme.titleFont)
            
            VStack(spacing: 12) {
                ForEach(milestones.filter { $0 <= target || $0 <= currentStreak + 20 }, id: \.self) { milestone in
                    HabitMilestoneRow(
                        day: milestone,
                        isReached: currentStreak >= milestone,
                        description: milestoneDescription(milestone)
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func milestoneDescription(_ day: Int) -> String {
        switch day {
        case 7: return "初见成效"
        case 21: return "习惯初步养成"
        case 66: return "习惯完全形成"
        case 100: return "坚持百日"
        default: return "继续前进"
        }
    }
}

struct HabitMilestoneRow: View {
    let day: Int
    let isReached: Bool
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(isReached ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                if isReached {
                    Image(systemName: "checkmark")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "flag")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(day)天")
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isReached {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(12)
        .background(isReached ? Color.green.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct HabitStatsSection: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("统计数据")
                .font(Theme.titleFont)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HabitStatBox(title: "总打卡", value: "\(habit.records.count)", icon: "checkmark.circle")
                HabitStatBox(title: "最长连续", value: "\(longestStreak)天", icon: "flame")
                HabitStatBox(title: "本周完成", value: "\(weeklyCount)次", icon: "calendar")
                HabitStatBox(title: "完成率", value: "\(completionRate)%", icon: "percent")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var longestStreak: Int {
        // 计算历史最长连续天数
        var maxStreak = 0
        var currentStreak = 0
        let sortedRecords = habit.records.sorted { $0.date < $1.date }
        
        for (index, record) in sortedRecords.enumerated() {
            if index == 0 {
                currentStreak = 1
            } else {
                let prevDate = sortedRecords[index - 1].date
                if Calendar.current.isDate(record.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!) {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
        }
        
        return max(maxStreak, currentStreak)
    }
    
    private var weeklyCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return habit.records.filter { $0.date >= weekAgo }.count
    }
    
    private var completionRate: Int {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: habit.createdDate, to: Date()).day ?? 1
        guard daysSinceCreation > 0 else { return 0 }
        return Int(Double(habit.records.count) / Double(daysSinceCreation) * 100)
    }
}

struct HabitStatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.habitGradient)
            
            Text(value)
                .font(.title3.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct HabitScoreSection: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("习惯评分")
                .font(Theme.titleFont)
            
            VStack(spacing: 16) {
                // 总分
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: habit.habitScore / 100.0)
                        .stroke(
                            LinearGradient(
                                colors: scoreGradientColors(habit.habitScore),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1), value: habit.habitScore)
                    
                    VStack {
                        Text("\(Int(habit.habitScore))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        Text("分")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // 评分详情
                VStack(spacing: 8) {
                    ScoreDetailRow(title: "连续性", score: calculateStreakScore(), maxScore: 40)
                    ScoreDetailRow(title: "总次数", score: calculateTotalScore(), maxScore: 30)
                    ScoreDetailRow(title: "近期完成", score: calculateRecentScore(), maxScore: 30)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .onAppear {
            _ = habit.calculateHabitScore()
        }
    }
    
    private func scoreGradientColors(_ score: Double) -> [Color] {
        if score >= 80 { return [.green, .mint] }
        if score >= 60 { return [.yellow, .orange] }
        return [.orange, .red]
    }
    
    private func calculateStreakScore() -> Double {
        let streak = habit.getCurrentStreak()
        return min(Double(streak) / 30.0, 1.0) * 40
    }
    
    private func calculateTotalScore() -> Double {
        return min(Double(habit.records.count) / 100.0, 1.0) * 30
    }
    
    private func calculateRecentScore() -> Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentCount = habit.records.filter { $0.date >= weekAgo }.count
        return min(Double(recentCount) / 7.0, 1.0) * 30
    }
}

struct ScoreDetailRow: View {
    let title: String
    let score: Double
    let maxScore: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(score))/\(Int(maxScore))")
                .font(.caption.bold())
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.habitGradient)
                        .frame(width: geo.size.width * (score / maxScore))
                }
            }
            .frame(width: 80, height: 6)
        }
    }
}

struct CheckInCalendarSection: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("打卡日历")
                .font(Theme.titleFont)
            
            // 最近30天的打卡情况
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<30, id: \.self) { day in
                    let date = Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date()
                    let hasRecord = habit.records.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    
                    VStack(spacing: 4) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.caption2)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hasRecord ? Color(hex: habit.colorHex) : Color.gray.opacity(0.2))
                            .frame(height: 30)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct MotivationSection: View {
    @Bindable var habit: Habit
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("坚持的理由")
                    .font(Theme.titleFont)
                
                Spacer()
                
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "完成" : "编辑")
                        .font(.caption)
                }
            }
            
            if isEditing {
                TextEditor(text: $habit.motivationNote)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                if habit.motivationNote.isEmpty {
                    Text("添加您坚持这个习惯的原因，在想放弃时提醒自己")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(habit.motivationNote)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

