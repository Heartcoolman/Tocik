//
//  DataCleanupView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 数据清理
//

import SwiftUI
import SwiftData

struct DataCleanupView: View {
    @Query private var todos: [TodoItem]
    @Query private var notes: [Note]
    @Query private var attachments: [Attachment]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var goals: [Goal]
    @Environment(\.modelContext) private var context
    
    @State private var suggestions: [DataCleanupSuggestion] = []
    @State private var selectedSuggestions: Set<DataCleanupSuggestion.CleanupType> = []
    @State private var isAnalyzing = false
    @State private var showCleanupConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isAnalyzing {
                    ProgressView("分析中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if suggestions.isEmpty {
                    EmptyCleanupView(onAnalyze: analyzeData)
                } else {
                    List {
                        Section {
                            Text("以下数据可以安全清理，释放存储空间")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(suggestions, id: \.type) { suggestion in
                            CleanupSuggestionRow(
                                suggestion: suggestion,
                                isSelected: selectedSuggestions.contains(suggestion.type),
                                onToggle: {
                                    toggleSelection(suggestion.type)
                                }
                            )
                        }
                        
                        Section {
                            HStack {
                                Text("预计释放空间")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(totalSpaceToFree)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // 清理按钮
                    if !selectedSuggestions.isEmpty {
                        Button(action: { showCleanupConfirmation = true }) {
                            Text("清理选中项 (\(selectedSuggestions.count))")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.gradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("数据清理")
            .toolbar {
                if !suggestions.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("重新分析") {
                            analyzeData()
                        }
                    }
                }
            }
            .alert("确认清理？", isPresented: $showCleanupConfirmation) {
                Button("取消", role: .cancel) {}
                Button("清理", role: .destructive) {
                    performCleanup()
                }
            } message: {
                Text("此操作不可撤销，确定要清理选中的数据吗？")
            }
            .onAppear {
                if suggestions.isEmpty {
                    analyzeData()
                }
            }
        }
    }
    
    private var totalSpaceToFree: String {
        let total = suggestions
            .filter { selectedSuggestions.contains($0.type) }
            .reduce(0) { $0 + $1.estimatedSpace }
        return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
    
    private func toggleSelection(_ type: DataCleanupSuggestion.CleanupType) {
        if selectedSuggestions.contains(type) {
            selectedSuggestions.remove(type)
        } else {
            selectedSuggestions.insert(type)
        }
        HapticManager.shared.selection()
    }
    
    private func analyzeData() {
        isAnalyzing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analyzed = DataCleanupAnalyzer.analyzecleanupOpportunities(
                todos: todos,
                notes: notes,
                attachments: attachments,
                pomodoroSessions: pomodoroSessions,
                goals: goals
            )
            
            DispatchQueue.main.async {
                suggestions = analyzed
                isAnalyzing = false
            }
        }
    }
    
    private func performCleanup() {
        let calendar = Calendar.current
        
        for type in selectedSuggestions {
            switch type {
            case .oldCompletedTodos:
                let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())!
                let toDelete = todos.filter {
                    $0.isCompleted && ($0.completedDate ?? Date.distantPast) < threeMonthsAgo
                }
                toDelete.forEach { context.delete($0) }
                
            case .oldNoteVersions:
                for note in notes where note.versions.count > 10 {
                    let keep = Array(note.versions.suffix(10))
                    let delete = note.versions.filter { !keep.contains($0) }
                    delete.forEach { context.delete($0) }
                }
                
            case .oldPomodoroSessions:
                let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date())!
                let toDelete = pomodoroSessions.filter { $0.startTime < sixMonthsAgo }
                toDelete.forEach { context.delete($0) }
                
            case .archivedGoals:
                let toDelete = goals.filter { $0.isArchived }
                toDelete.forEach { context.delete($0) }
                
            case .unusedAttachments:
                // 这需要更复杂的逻辑来判断未使用的附件
                break
            }
        }
        
        selectedSuggestions.removeAll()
        analyzeData()
        HapticManager.shared.success()
    }
}

struct EmptyCleanupView: View {
    let onAnalyze: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(Theme.primaryGradient)
            
            Text("数据很干净")
                .font(.title.bold())
            
            Text("点击分析查找可清理的数据")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: onAnalyze) {
                Label("开始分析", systemImage: "magnifyingglass")
                    .font(.headline)
                    .padding()
                    .background(Theme.primaryGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CleanupSuggestionRow: View {
    let suggestion: DataCleanupSuggestion
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // 选择框
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.description)
                        .font(.subheadline)
                    
                    HStack {
                        Text("\(suggestion.itemCount)项")
                            .font(.caption)
                        
                        Text("·")
                            .font(.caption)
                        
                        Text(suggestion.formattedSize)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

