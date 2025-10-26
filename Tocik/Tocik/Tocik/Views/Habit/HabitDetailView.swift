//
//  HabitDetailView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let habit: Habit
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 习惯信息卡片
                    VStack(spacing: 16) {
                        Image(systemName: habit.icon)
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: habit.colorHex))
                        
                        Text(habit.name)
                            .font(.system(size: 28, weight: .bold))
                        
                        HStack(spacing: 40) {
                            VStack {
                                Text("\(habit.getCurrentStreak())")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(hex: habit.colorHex))
                                Text("连续天数")
                                    .font(Theme.captionFont)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(habit.records.count)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(hex: habit.colorHex))
                                Text("总计次数")
                                    .font(Theme.captionFont)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(Theme.cornerRadius)
                    .shadow(radius: 2)
                    .padding()
                    
                    // 完成历史
                    VStack(alignment: .leading, spacing: 12) {
                        Text("完成历史")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        if habit.records.isEmpty {
                            Text("暂无记录")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(habit.records.sorted(by: { $0.date > $1.date })) { record in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    Text(record.date.formatted("yyyy年MM月dd日 HH:mm"))
                                        .font(Theme.bodyFont)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(Theme.smallCornerRadius)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 删除按钮
                    Button(role: .destructive, action: deleteHabit) {
                        Text("删除习惯")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(Theme.smallCornerRadius)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("习惯详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitRecord.self, configurations: config)
    
    let habit = Habit(name: "每日阅读", icon: "book.fill", colorHex: "#4A90E2")
    
    return HabitDetailView(habit: habit)
        .modelContainer(container)
}

