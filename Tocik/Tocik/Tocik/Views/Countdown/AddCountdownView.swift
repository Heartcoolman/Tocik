//
//  AddCountdownView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var eventDescription = ""
    @State private var targetDate = Date()
    @State private var selectedIcon = "calendar"
    @State private var selectedColor = "#FF6B6B"
    @State private var isImportant = false
    
    let icons = [
        "calendar", "graduationcap.fill", "heart.fill", "gift.fill",
        "airplane", "star.fill", "flag.fill", "trophy.fill"
    ]
    
    let colors = [
        "#FF6B6B", "#4A90E2", "#4ECDC4", "#FFD93D",
        "#A78BFA", "#FB923C", "#F472B6", "#34D399"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextField("描述（可选）", text: $eventDescription)
                }
                
                Section("目标日期") {
                    DatePicker("日期", selection: $targetDate, displayedComponents: .date)
                }
                
                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Theme.countdownColor : Color(.systemGray6))
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
                
                Section {
                    Toggle("标记为重要", isOn: $isImportant)
                }
            }
            .navigationTitle("新建倒数日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCountdown()
                    }
                    .disabled(title.isBlank)
                }
            }
        }
    }
    
    private func saveCountdown() {
        let countdown = Countdown(
            title: title,
            targetDate: targetDate,
            eventDescription: eventDescription,
            colorHex: selectedColor,
            icon: selectedIcon,
            isImportant: isImportant
        )
        
        modelContext.insert(countdown)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: Countdown.self, inMemory: true)
}

