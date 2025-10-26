//
//  TodoSmartSortView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 待办智能排序
//

import SwiftUI
import SwiftData

struct TodoSmartSortView: View {
    @Query private var todos: [TodoItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var sortedTodos: [TodoItem] = []
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isAnalyzing {
                    ProgressView("分析中...")
                        .padding()
                } else if sortedTodos.isEmpty {
                    VStack(spacing: Theme.spacing.medium) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.todoGradient)
                        
                        Text("智能排序")
                            .font(Theme.titleFont)
                        
                        Text("基于优先级、截止日期和预估时长\n为您推荐最佳执行顺序")
                            .font(Theme.bodyFont)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: performSmartSort) {
                            Label("开始分析", systemImage: "sparkles")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.todoGradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        Section {
                            Text("以下是根据您的任务特点推荐的执行顺序")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(Array(sortedTodos.enumerated()), id: \.element.id) { index, todo in
                            HStack {
                                // 排名
                                Text("\(index + 1)")
                                    .font(.title2.bold())
                                    .foregroundStyle(rankGradient(index))
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(todo.title)
                                        .font(.headline)
                                    
                                    HStack {
                                        PriorityBadge(priority: todo.priority)
                                        
                                        if let dueDate = todo.dueDate {
                                            Label(formatDueDate(dueDate), systemImage: "calendar")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Label("\(todo.estimatedPomodoros)个番茄钟", systemImage: "timer")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // 得分
                                VStack {
                                    Text(String(format: "%.0f", todo.smartRank))
                                        .font(.caption.bold())
                                    Text("分")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("智能排序")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                if !sortedTodos.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("重新分析") {
                            performSmartSort()
                        }
                    }
                }
            }
        }
    }
    
    private func performSmartSort() {
        isAnalyzing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let incompleteTodos = todos.filter { !$0.isCompleted }
            
            // 计算每个任务的智能排序分数
            for todo in incompleteTodos {
                _ = todo.calculateSmartRank()
            }
            
            // 按分数排序
            sortedTodos = incompleteTodos.sorted { $0.smartRank > $1.smartRank }
            isAnalyzing = false
            HapticManager.shared.success()
        }
    }
    
    private func rankGradient(_ index: Int) -> LinearGradient {
        switch index {
        case 0:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 1:
            return LinearGradient(colors: [.gray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [.orange, .brown], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.blue.opacity(0.6), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if days < 0 {
            return "已逾期"
        } else if days == 0 {
            return "今天"
        } else if days == 1 {
            return "明天"
        } else {
            return "\(days)天后"
        }
    }
}

struct PriorityBadge: View {
    let priority: TodoItem.Priority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color(hex: priority.colorHex).opacity(0.2))
            .foregroundColor(Color(hex: priority.colorHex))
            .clipShape(Capsule())
    }
}

