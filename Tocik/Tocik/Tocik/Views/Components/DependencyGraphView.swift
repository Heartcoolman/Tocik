//
//  DependencyGraphView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 任务依赖关系图
//

import SwiftUI

struct DependencyGraphView: View {
    let todos: [TodoItem]
    let selectedTodo: TodoItem
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 40) {
                // 当前任务
                TaskNode(todo: selectedTodo, type: .current)
                
                // 依赖任务（需要先完成的）
                if !dependencies.isEmpty {
                    VStack(spacing: 20) {
                        Text("↑ 依赖于")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            ForEach(dependencies) { todo in
                                TaskNode(todo: todo, type: .dependency)
                            }
                        }
                    }
                }
                
                // 被依赖的任务（依赖当前任务的）
                if !dependents.isEmpty {
                    VStack(spacing: 20) {
                        Text("↓ 被以下任务依赖")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            ForEach(dependents) { todo in
                                TaskNode(todo: todo, type: .dependent)
                            }
                        }
                    }
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var dependencies: [TodoItem] {
        todos.filter { selectedTodo.dependencies.contains($0.id) }
    }
    
    private var dependents: [TodoItem] {
        todos.filter { $0.dependencies.contains(selectedTodo.id) }
    }
}

struct TaskNode: View {
    let todo: TodoItem
    let type: NodeType
    
    enum NodeType {
        case current
        case dependency
        case dependent
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 节点
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(nodeColor)
                    .frame(width: 120, height: 80)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                
                VStack(spacing: 4) {
                    if todo.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Text(todo.title)
                        .font(.caption.bold())
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    PriorityBadge(priority: todo.priority)
                }
            }
            
            // 标签
            if type == .current {
                Text("当前")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var nodeColor: LinearGradient {
        switch type {
        case .current:
            return LinearGradient(
                colors: [Color(hex: "#667EEA").opacity(0.3), Color(hex: "#48C6EF").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dependency:
            if todo.isCompleted {
                return LinearGradient(colors: [.green.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            return LinearGradient(colors: [.orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dependent:
            return LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

