//
//  AddTodoView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: TodoItem.Priority = .medium
    @State private var category = "通用"
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("待办事项", text: $title)
                    
                    TextField("备注（可选）", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(hex: priority.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("分类") {
                    TextField("分类", text: $category)
                }
                
                Section {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("截止时间", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("新建待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTodo()
                    }
                    .disabled(title.isBlank)
                }
            }
        }
    }
    
    private func saveTodo() {
        let todo = TodoItem(
            title: title,
            notes: notes,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            category: category
        )
        
        modelContext.insert(todo)
        try? modelContext.save()
        
        // 如果设置了截止日期，添加通知
        if hasDueDate, dueDate > Date() {
            notificationManager.scheduleTodoNotification(
                todoId: todo.id,
                title: title,
                dueDate: dueDate
            )
        }
        
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .modelContainer(for: TodoItem.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}

