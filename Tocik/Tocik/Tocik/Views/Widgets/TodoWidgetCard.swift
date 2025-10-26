//
//  TodoWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 待办小部件卡片
//

import SwiftUI
import SwiftData

struct TodoWidgetCard: View {
    @Query private var todos: [TodoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(Theme.todoGradient)
                Text("待办")
                    .font(.headline)
                
                Spacer()
                
                Text("\(pendingCount)项")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 数据
            VStack(spacing: 8) {
                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.todoGradient)
                            .frame(width: geo.size.width * completionRate)
                    }
                }
                .frame(height: 12)
                
                // 统计
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已完成")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(completedCount)")
                            .font(.title3.bold())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("完成率")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(completionRate * 100))%")
                            .font(.title3.bold())
                            .foregroundStyle(Theme.todoGradient)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var completedCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    private var pendingCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    private var completionRate: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todos.count)
    }
}

