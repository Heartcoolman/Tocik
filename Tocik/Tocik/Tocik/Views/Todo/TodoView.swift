//
//  TodoView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct TodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdDate, order: .reverse) private var todos: [TodoItem]
    
    @State private var showingAddTodo = false
    @State private var filterCompleted = false
    @State private var selectedPriority: TodoItem.Priority?
    
    var filteredTodos: [TodoItem] {
        todos.filter { todo in
            (!filterCompleted || !todo.isCompleted) &&
            (selectedPriority == nil || todo.priority == selectedPriority)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if filteredTodos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无待办事项")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        // 按优先级分组
                        ForEach(TodoItem.Priority.allCases.reversed(), id: \.self) { priority in
                            let priorityTodos = filteredTodos.filter { $0.priority == priority }
                            if !priorityTodos.isEmpty {
                                Section(header: Text(priority.displayName)) {
                                    ForEach(priorityTodos) { todo in
                                        TodoRow(todo: todo)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    deleteTodo(todo)
                                                } label: {
                                                    Label("删除", systemImage: "trash")
                                                }
                                            }
                                            .swipeActions(edge: .leading) {
                                                Button {
                                                    toggleComplete(todo)
                                                } label: {
                                                    Label(todo.isCompleted ? "未完成" : "完成", 
                                                          systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                                }
                                                .tint(.green)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { selectedPriority = nil }) {
                            Label("全部", systemImage: selectedPriority == nil ? "checkmark" : "")
                        }
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                            Button(action: { selectedPriority = priority }) {
                                Label(priority.displayName, systemImage: selectedPriority == priority ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Theme.todoColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.todoColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
            }
        }
    }
    
    private func toggleComplete(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        if todo.isCompleted {
            todo.completedDate = Date()
        } else {
            todo.completedDate = nil
        }
        try? modelContext.save()
    }
    
    private func deleteTodo(_ todo: TodoItem) {
        modelContext.delete(todo)
        try? modelContext.save()
    }
}

struct TodoRow: View {
    let todo: TodoItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            // 优先级彩色条
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: todo.priority.colorHex), Color(hex: todo.priority.colorHex).opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)
            
            HStack(spacing: Theme.spacing.medium) {
                // 完成状态
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        todo.isCompleted ?
                        LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color(hex: todo.priority.colorHex), Color(hex: todo.priority.colorHex).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(todo.title)
                        .font(.system(size: 17, weight: .medium))
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    if !todo.notes.isEmpty {
                        Text(todo.notes)
                            .font(Theme.captionFont)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: Theme.spacing.small) {
                        if let dueDate = todo.dueDate {
                            Label(dueDate.formatted("MM/dd HH:mm"), systemImage: "calendar")
                                .font(.caption2)
                                .foregroundColor(dueDate < Date() && !todo.isCompleted ? .red : .secondary)
                        }
                        
                        Text(todo.category)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: todo.priority.colorHex).opacity(0.15))
                            .cornerRadius(6)
                        
                        if todo.pomodoroCount > 0 {
                            Label("\(todo.pomodoroCount)🍅", systemImage: "timer")
                                .font(.caption2)
                                .foregroundColor(Theme.pomodoroColor)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.leading, Theme.spacing.medium)
            .padding(.vertical, Theme.spacing.medium)
        }
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(.systemGray6)
                } else {
                    Color.white
                }
                
                // 渐变叠加
                LinearGradient(
                    colors: [Color(hex: todo.priority.colorHex).opacity(0.05), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TodoView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

