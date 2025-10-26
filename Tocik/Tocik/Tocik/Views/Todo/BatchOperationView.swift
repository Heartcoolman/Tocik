//
//  BatchOperationView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 批量操作
//

import SwiftUI
import SwiftData

struct BatchOperationView: View {
    @Query private var todos: [TodoItem]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTodos: Set<UUID> = []
    @State private var showActionSheet = false
    @State private var actionType: BatchAction?
    
    enum BatchAction: Equatable {
        case complete
        case delete
        case setPriority(TodoItem.Priority)
        case setCategory(String)
        case addTag(String)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 选择状态栏
                if !selectedTodos.isEmpty {
                    HStack {
                        Text("已选择 \(selectedTodos.count) 项")
                            .font(.subheadline.bold())
                        
                        Spacer()
                        
                        Button("全选") {
                            selectAll()
                        }
                        
                        Button("取消") {
                            selectedTodos.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                
                // 待办列表
                List {
                    ForEach(todos.filter { !$0.isCompleted }) { todo in
                        BatchTodoRow(
                            todo: todo,
                            isSelected: selectedTodos.contains(todo.id),
                            onToggle: {
                                toggleSelection(todo)
                            }
                        )
                    }
                }
                
                // 操作按钮
                if !selectedTodos.isEmpty {
                    BatchActionButtons(
                        onComplete: {
                            performAction(.complete)
                        },
                        onDelete: {
                            showActionSheet = true
                            actionType = .delete
                        },
                        onMore: {
                            showActionSheet = true
                        }
                    )
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("批量操作")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("批量操作", isPresented: $showActionSheet) {
                if actionType == .delete {
                    Button("删除选中项", role: .destructive) {
                        performAction(.delete)
                    }
                    Button("取消", role: .cancel) {}
                } else {
                    Button("标记为高优先级") {
                        performAction(.setPriority(.high))
                    }
                    Button("标记为中优先级") {
                        performAction(.setPriority(.medium))
                    }
                    Button("标记为低优先级") {
                        performAction(.setPriority(.low))
                    }
                    Button("取消", role: .cancel) {}
                }
            }
        }
    }
    
    private func toggleSelection(_ todo: TodoItem) {
        if selectedTodos.contains(todo.id) {
            selectedTodos.remove(todo.id)
        } else {
            selectedTodos.insert(todo.id)
        }
        HapticManager.shared.selection()
    }
    
    private func selectAll() {
        selectedTodos = Set(todos.filter { !$0.isCompleted }.map { $0.id })
        HapticManager.shared.light()
    }
    
    private func performAction(_ action: BatchAction) {
        let selectedItems = todos.filter { selectedTodos.contains($0.id) }
        
        switch action {
        case .complete:
            for todo in selectedItems {
                todo.isCompleted = true
                todo.completedDate = Date()
            }
            HapticManager.shared.pattern(.complete)
            
        case .delete:
            for todo in selectedItems {
                context.delete(todo)
            }
            HapticManager.shared.pattern(.delete)
            
        case .setPriority(let priority):
            for todo in selectedItems {
                todo.priority = priority
            }
            HapticManager.shared.success()
            
        case .setCategory(let category):
            for todo in selectedItems {
                todo.category = category
            }
            HapticManager.shared.success()
            
        case .addTag(let tag):
            for todo in selectedItems {
                var tags = todo.tags
                if !tags.contains(tag) {
                    tags.append(tag)
                    todo.tags = tags
                }
            }
            HapticManager.shared.success()
        }
        
        selectedTodos.removeAll()
    }
}

struct BatchTodoRow: View {
    let todo: TodoItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // 选择框
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Theme.todoGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.subheadline)
                    
                    HStack {
                        PriorityBadge(priority: todo.priority)
                        
                        if !todo.category.isEmpty {
                            Text(todo.category)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct BatchActionButtons: View {
    let onComplete: () -> Void
    let onDelete: () -> Void
    let onMore: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            Button(action: onComplete) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                    Text("完成")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Button(action: onDelete) {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("删除")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Button(action: onMore) {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis.circle")
                    Text("更多")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

