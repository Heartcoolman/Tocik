//
//  HabitView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct HabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if habits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("开始追踪您的习惯")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(habits) { habit in
                                HabitCard(habit: habit)
                                    .onTapGesture {
                                        selectedHabit = habit
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("习惯追踪")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.habitColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
        }
    }
}

struct HabitCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    let habit: Habit
    
    @State private var isCheckedToday = false
    
    var habitGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: habit.colorHex), Color(hex: habit.colorHex).opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.large) {
            HStack(spacing: Theme.spacing.medium) {
                // 渐变图标
                ZStack {
                    Circle()
                        .fill(habitGradient.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(habitGradient)
                        .symbolRenderingMode(.hierarchical)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(habitGradient)
                        
                        Text("\(habit.getCurrentStreak())天连续")
                            .font(Theme.captionFont)
                            .foregroundStyle(habitGradient)
                    }
                }
                
                Spacer()
                
                // 打卡按钮（现代化）
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    toggleToday()
                }) {
                    Image(systemName: isCheckedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            isCheckedToday ?
                            LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(isCheckedToday ? 1.1 : 1.0)
                .animation(Theme.bounceAnimation, value: isCheckedToday)
            }
            
            // 最近7天热力图（渐变设计）
            HStack(spacing: 10) {
                ForEach(0..<7, id: \.self) { i in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + i, to: Date())!
                    let isChecked = hasRecordOn(date: date)
                    
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isChecked ?
                                habitGradient :
                                LinearGradient(colors: [Color(.systemGray5), Color(.systemGray5)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isChecked ? Color(hex: habit.colorHex).opacity(0.3) : Color.clear, lineWidth: 1.5)
                            )
                            .shadow(color: isChecked ? Color(hex: habit.colorHex).opacity(0.3) : .clear, radius: 8, y: 4)
                        
                        Text(date.formatted("E"))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(Theme.spacing.large)
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(.systemGray6)
                } else {
                    Color.white
                }
                
                // 渐变背景叠加
                habitGradient
                    .opacity(0.03)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(habitGradient.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.08), radius: 15, x: 0, y: 8)
        .onAppear {
            checkTodayStatus()
        }
    }
    
    private func checkTodayStatus() {
        isCheckedToday = hasRecordOn(date: Date())
    }
    
    private func hasRecordOn(date: Date) -> Bool {
        habit.records.contains { record in
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func toggleToday() {
        if isCheckedToday {
            // 移除今天的记录
            if let recordIndex = habit.records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                let record = habit.records[recordIndex]
                modelContext.delete(record)
                habit.records.remove(at: recordIndex)
            }
        } else {
            // 添加今天的记录
            let record = HabitRecord(date: Date())
            modelContext.insert(record)
            habit.records.append(record)
        }
        
        try? modelContext.save()
        isCheckedToday.toggle()
    }
}

#Preview {
    HabitView()
        .modelContainer(for: Habit.self, inMemory: true)
}

