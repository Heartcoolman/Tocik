//
//  AddEventView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var eventDescription = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var hasReminder = false
    @State private var reminderMinutes = 30
    @State private var selectedColor = "#FF6B6B"
    
    let colors = ["#FF6B6B", "#4A90E2", "#4ECDC4", "#FFD93D", "#95E1D3", "#A78BFA"]
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _startDate = State(initialValue: selectedDate)
        _endDate = State(initialValue: Calendar.current.date(byAdding: .hour, value: 1, to: selectedDate)!)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("事件信息") {
                    TextField("标题", text: $title)
                    TextField("描述（可选）", text: $eventDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("时间") {
                    Toggle("全天", isOn: $isAllDay)
                    
                    DatePicker("开始", selection: $startDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("结束", selection: $endDate, displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
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
                    Toggle("事件提醒", isOn: $hasReminder)
                    
                    if hasReminder {
                        Picker("提前提醒", selection: $reminderMinutes) {
                            Text("事件发生时").tag(0)
                            Text("5分钟前").tag(5)
                            Text("15分钟前").tag(15)
                            Text("30分钟前").tag(30)
                            Text("1小时前").tag(60)
                            Text("1天前").tag(1440)
                        }
                    }
                }
            }
            .navigationTitle("新建事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(title.isBlank)
                }
            }
        }
    }
    
    private func saveEvent() {
        let event = CalendarEvent(
            title: title,
            eventDescription: eventDescription,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            reminderMinutes: hasReminder ? reminderMinutes : nil,
            colorHex: selectedColor
        )
        
        modelContext.insert(event)
        try? modelContext.save()
        
        // 设置提醒
        if hasReminder {
            notificationManager.scheduleEventNotification(
                eventId: event.id,
                title: title,
                date: startDate,
                minutesBefore: reminderMinutes
            )
        }
        
        dismiss()
    }
}

#Preview {
    AddEventView(selectedDate: Date())
        .modelContainer(for: CalendarEvent.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}

