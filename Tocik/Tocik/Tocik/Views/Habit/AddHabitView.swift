//
//  AddHabitView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#4A90E2"
    @State private var frequency: Habit.Frequency = .daily
    @State private var targetCount = 1
    
    let icons = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "pencil", "dumbbell.fill", "figure.run",
        "cup.and.saucer.fill", "drop.fill", "moon.stars.fill", "sun.max.fill"
    ]
    
    let colors = [
        "#4A90E2", "#FF6B6B", "#4ECDC4", "#FFD93D",
        "#95E1D3", "#A78BFA", "#FB923C", "#F472B6"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("习惯名称") {
                    TextField("例如：每日阅读", text: $name)
                }
                
                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Theme.habitColor : Color(.systemGray6))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("颜色") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("频率") {
                    Picker("频率", selection: $frequency) {
                        Text("每天").tag(Habit.Frequency.daily)
                        Text("每周").tag(Habit.Frequency.weekly)
                    }
                    .pickerStyle(.segmented)
                    
                    Stepper("目标：\(targetCount)次", value: $targetCount, in: 1...10)
                }
            }
            .navigationTitle("新建习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveHabit()
                    }
                    .disabled(name.isBlank)
                }
            }
        }
    }
    
    private func saveHabit() {
        let habit = Habit(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColor,
            frequency: frequency,
            targetCount: targetCount
        )
        
        modelContext.insert(habit)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: Habit.self, inMemory: true)
}

