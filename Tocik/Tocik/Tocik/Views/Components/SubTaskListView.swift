//
//  SubTaskListView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 子任务列表组件
//

import SwiftUI
import SwiftData

struct SubTaskListView: View {
    @Bindable var todo: TodoItem
    @State private var newSubTaskTitle = ""
    @State private var showAddSubTask = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.small) {
            // 标题和进度
            HStack {
                Text("子任务")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                if !todo.subTasks.isEmpty {
                    Text("\(completedCount)/\(todo.subTasks.count)")
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                    
                    // 进度条
                    ProgressView(value: todo.subTasksProgress())
                        .frame(width: 60)
                }
                
                Button(action: { showAddSubTask.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.todoGradient)
                }
            }
            
            // 子任务列表
            if !todo.subTasks.isEmpty {
                VStack(spacing: Theme.spacing.small) {
                    ForEach(todo.subTasks.sorted { $0.orderIndex < $1.orderIndex }) { subTask in
                        SubTaskRow(subTask: subTask)
                    }
                }
            }
            
            // 添加子任务输入框
            if showAddSubTask {
                HStack {
                    TextField("新子任务", text: $newSubTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("添加") {
                        addSubTask()
                    }
                    .disabled(newSubTaskTitle.isEmpty)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var completedCount: Int {
        todo.subTasks.filter { $0.isCompleted }.count
    }
    
    private func addSubTask() {
        let subTask = SubTask(
            title: newSubTaskTitle,
            orderIndex: todo.subTasks.count
        )
        todo.subTasks.append(subTask)
        newSubTaskTitle = ""
        showAddSubTask = false
        HapticManager.shared.light()
    }
}

struct SubTaskRow: View {
    @Bindable var subTask: SubTask
    
    var body: some View {
        HStack(spacing: Theme.spacing.small) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    subTask.isCompleted.toggle()
                    if subTask.isCompleted {
                        subTask.completedDate = Date()
                        HapticManager.shared.success()
                    } else {
                        subTask.completedDate = nil
                    }
                }
            }) {
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(subTask.isCompleted ? Theme.todoGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
            }
            
            Text(subTask.title)
                .font(Theme.bodyFont)
                .strikethrough(subTask.isCompleted)
                .foregroundColor(subTask.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

