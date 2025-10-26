//
//  TodoSelectionView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct TodoSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTodo: TodoItem?
    let todos: [TodoItem]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(todos) { todo in
                    Button(action: {
                        selectedTodo = todo
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todo.title)
                                    .font(Theme.bodyFont)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Circle()
                                        .fill(Color(hex: todo.priority.colorHex))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(todo.priority.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if todo.estimatedPomodoros > 0 {
                                        Text("• 预估\(todo.estimatedPomodoros)个番茄钟")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if selectedTodo?.id == todo.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TodoSelectionView(
        selectedTodo: .constant(nil),
        todos: []
    )
}

