//
//  PersonalRecordsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 个人记录展示
//

import SwiftUI
import SwiftData

struct PersonalRecordsView: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var notes: [Note]
    @Query private var flashCards: [FlashCard]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 顶部荣誉横幅
                HonorBannerView()
                
                // 番茄钟记录
                RecordSection(
                    title: "🍅 番茄钟记录",
                    records: pomodoroRecords,
                    gradient: Theme.pomodoroGradient
                )
                
                // 待办记录
                RecordSection(
                    title: "✅ 待办记录",
                    records: todoRecords,
                    gradient: Theme.todoGradient
                )
                
                // 习惯记录
                RecordSection(
                    title: "⭐️ 习惯记录",
                    records: habitRecords,
                    gradient: Theme.habitGradient
                )
                
                // 学习记录
                RecordSection(
                    title: "📚 学习记录",
                    records: studyRecords,
                    gradient: Theme.flashcardGradient
                )
                
                // 持续记录
                RecordSection(
                    title: "🔥 连续记录",
                    records: streakRecords,
                    gradient: LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .padding()
        }
        .navigationTitle("个人记录")
    }
    
    // MARK: - 计算记录
    
    private var pomodoroRecords: [PersonalRecord] {
        let total = pomodoroSessions.filter { $0.isCompleted }.count
        let maxDaily = calculateMaxDailyPomodoros()
        let avgFocus = pomodoroSessions.isEmpty ? 0 : pomodoroSessions.map { $0.focusScore }.reduce(0, +) / Double(pomodoroSessions.count)
        
        return [
            PersonalRecord(title: "总完成数", value: "\(total)个", icon: "timer"),
            PersonalRecord(title: "单日最多", value: "\(maxDaily)个", icon: "calendar.badge.clock"),
            PersonalRecord(title: "平均专注度", value: String(format: "%.0f分", avgFocus), icon: "brain"),
            PersonalRecord(title: "累计时长", value: "\(total * 25)分钟", icon: "clock")
        ]
    }
    
    private var todoRecords: [PersonalRecord] {
        let completed = todos.filter { $0.isCompleted }.count
        let total = todos.count
        let maxDaily = calculateMaxDailyTodos()
        let rate = total > 0 ? Double(completed) / Double(total) * 100 : 0
        
        return [
            PersonalRecord(title: "总完成数", value: "\(completed)个", icon: "checkmark.circle"),
            PersonalRecord(title: "完成率", value: String(format: "%.0f%%", rate), icon: "percent"),
            PersonalRecord(title: "单日最多", value: "\(maxDaily)个", icon: "calendar"),
            PersonalRecord(title: "平均耗时", value: "\(calculateAvgTaskTime())分钟", icon: "timer")
        ]
    }
    
    private var habitRecords: [PersonalRecord] {
        let totalChecks = habits.reduce(0) { $0 + $1.records.count }
        let maxStreak = habits.map { $0.getCurrentStreak() }.max() ?? 0
        let avgScore = habits.isEmpty ? 0 : habits.map { $0.habitScore }.reduce(0, +) / Double(habits.count)
        
        return [
            PersonalRecord(title: "总打卡数", value: "\(totalChecks)次", icon: "checkmark.square"),
            PersonalRecord(title: "最长连续", value: "\(maxStreak)天", icon: "flame.fill"),
            PersonalRecord(title: "平均评分", value: String(format: "%.0f分", avgScore), icon: "star.fill"),
            PersonalRecord(title: "习惯数", value: "\(habits.count)个", icon: "list.bullet")
        ]
    }
    
    private var studyRecords: [PersonalRecord] {
        let totalNotes = notes.count
        let totalFlashCards = flashCards.count
        let totalReviews = flashCards.reduce(0) { $0 + $1.reviewCount }
        
        return [
            PersonalRecord(title: "笔记总数", value: "\(totalNotes)篇", icon: "doc.text"),
            PersonalRecord(title: "闪卡总数", value: "\(totalFlashCards)张", icon: "rectangle.stack"),
            PersonalRecord(title: "复习次数", value: "\(totalReviews)次", icon: "arrow.triangle.2.circlepath"),
            PersonalRecord(title: "总字数", value: "\(totalWords)", icon: "textformat.size")
        ]
    }
    
    private var streakRecords: [PersonalRecord] {
        let maxStreak = habits.map { $0.getCurrentStreak() }.max() ?? 0
        let currentStreaks = habits.filter { $0.getCurrentStreak() > 0 }.count
        let avgStreak = habits.isEmpty ? 0 : habits.map { Double($0.getCurrentStreak()) }.reduce(0, +) / Double(habits.count)
        
        return [
            PersonalRecord(title: "最长连续", value: "\(maxStreak)天", icon: "flame.fill"),
            PersonalRecord(title: "进行中的连续", value: "\(currentStreaks)个", icon: "chart.line.uptrend.xyaxis"),
            PersonalRecord(title: "平均连续", value: String(format: "%.0f天", avgStreak), icon: "chart.bar"),
        ]
    }
    
    // MARK: - 辅助方法
    
    private func calculateMaxDailyPomodoros() -> Int {
        let grouped = Dictionary(grouping: pomodoroSessions.filter { $0.isCompleted }) {
            Calendar.current.startOfDay(for: $0.startTime)
        }
        return grouped.values.map { $0.count }.max() ?? 0
    }
    
    private func calculateMaxDailyTodos() -> Int {
        let grouped = Dictionary(grouping: todos.filter { $0.isCompleted && $0.completedDate != nil }) {
            Calendar.current.startOfDay(for: $0.completedDate!)
        }
        return grouped.values.map { $0.count }.max() ?? 0
    }
    
    private func calculateAvgTaskTime() -> Int {
        let completedWithTime = todos.filter { $0.isCompleted && $0.actualCompletionTime > 0 }
        guard !completedWithTime.isEmpty else { return 0 }
        return completedWithTime.reduce(0) { $0 + $1.actualCompletionTime } / completedWithTime.count
    }
    
    private var totalWords: String {
        let total = notes.reduce(0) { $0 + $1.wordCount }
        if total >= 10000 {
            return String(format: "%.1f万", Double(total) / 10000.0)
        }
        return "\(total)"
    }
}

// MARK: - 子视图

struct HonorBannerView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("个人记录榜")
                .font(.title.bold())
            
            Text("记录您的每一个成就")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.1), .orange.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct RecordSection: View {
    let title: String
    let records: [PersonalRecord]
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text(title)
                .font(Theme.titleFont)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(records) { record in
                    RecordCard(record: record, gradient: gradient)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct RecordCard: View {
    let record: PersonalRecord
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: record.icon)
                .font(.title2)
                .foregroundStyle(gradient)
            
            Text(record.value)
                .font(.title3.bold())
            
            Text(record.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(gradient.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
}

