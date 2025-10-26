//
//  TaskDetailEnhancedView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 增强的任务详情视图
//

import SwiftUI
import SwiftData

struct TaskDetailEnhancedView: View {
    @Bindable var todo: TodoItem
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSubTaskAdd = false
    @State private var showCommentAdd = false
    @State private var showAttachmentPicker = false
    @State private var showRecurrencePicker = false
    @State private var showDependencyPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 任务标题和基本信息
                TaskHeaderCard(todo: todo)
                
                // 进度概览（如果有子任务）
                if !todo.subTasks.isEmpty {
                    TaskProgressCard(todo: todo)
                }
                
                // 子任务列表
                SubTaskListView(todo: todo)
                
                // 依赖关系
                if !todo.dependencies.isEmpty {
                    DependencySection(todo: todo, onManage: {
                        showDependencyPicker = true
                    })
                }
                
                // 重复规则
                RecurrenceSection(
                    rule: todo.recurrenceRule,
                    onEdit: { showRecurrencePicker = true }
                )
                
                // 附件
                if !todo.attachments.isEmpty {
                    AttachmentGalleryView(attachments: Binding(
                        get: { todo.attachments },
                        set: { todo.attachments = $0 }
                    ))
                }
                
                // 评论
                CommentsSection(
                    comments: todo.comments,
                    onAddComment: { showCommentAdd = true }
                )
                
                // 标签
                TaskTagsSection(todo: todo)
                
                // 番茄钟统计
                PomodoroStatsCard(
                    completed: todo.pomodoroCount,
                    estimated: todo.estimatedPomodoros
                )
                
                // 时间记录
                TimeTrackingCard(
                    created: todo.createdDate,
                    completed: todo.completedDate,
                    estimated: todo.estimatedPomodoros * 25,
                    actual: todo.actualCompletionTime
                )
            }
            .padding()
        }
        .navigationTitle("任务详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showAttachmentPicker = true }) {
                        Label("添加附件", systemImage: "paperclip")
                    }
                    
                    Button(action: { showRecurrencePicker = true }) {
                        Label("设置重复", systemImage: "repeat")
                    }
                    
                    Button(action: { showDependencyPicker = true }) {
                        Label("管理依赖", systemImage: "link")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: deleteTodo) {
                        Label("删除任务", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showRecurrencePicker) {
            RecurrenceRulePickerView(recurrenceRule: Binding(
                get: { todo.recurrenceRule },
                set: { todo.recurrenceRule = $0 }
            ))
        }
        .sheet(isPresented: $showCommentAdd) {
            AddCommentView(todo: todo)
        }
    }
    
    private func deleteTodo() {
        context.delete(todo)
        dismiss()
        HapticManager.shared.pattern(.delete)
    }
}

// MARK: - 子视图

struct TaskHeaderCard: View {
    @Bindable var todo: TodoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            // 标题
            TextField("任务标题", text: $todo.title)
                .font(.title2.bold())
            
            // 优先级和分类
            HStack {
                Menu {
                    ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                        Button(action: { todo.priority = priority }) {
                            HStack {
                                Text(priority.displayName)
                                if todo.priority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    PriorityBadge(priority: todo.priority)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(todo.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let dueDate = todo.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(formatDate(dueDate))
                    }
                    .font(.caption)
                    .foregroundColor(dueDateColor(dueDate))
                }
            }
            
            // 备注
            if !todo.notes.isEmpty {
                Divider()
                Text(todo.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func dueDateColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return .red }
        if days == 0 { return .orange }
        return .secondary
    }
}

struct TaskProgressCard: View {
    let todo: TodoItem
    
    var body: some View {
        HStack(spacing: Theme.spacing.xlarge) {
            // 子任务进度
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: todo.subTasksProgress())
                        .stroke(Theme.todoGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(todo.subTasksProgress() * 100))%")
                        .font(.headline.bold())
                }
                
                Text("子任务进度")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 统计
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(completedSubTasks)个已完成")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                    Text("\(pendingSubTasks)个待完成")
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("预计\(estimatedTime)分钟")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var completedSubTasks: Int {
        todo.subTasks.filter { $0.isCompleted }.count
    }
    
    private var pendingSubTasks: Int {
        todo.subTasks.filter { !$0.isCompleted }.count
    }
    
    private var estimatedTime: Int {
        pendingSubTasks * 15 // 假设每个子任务15分钟
    }
}

struct DependencySection: View {
    let todo: TodoItem
    let onManage: () -> Void
    
    @Query private var todos: [TodoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("依赖任务")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                Button("管理", action: onManage)
            }
            
            VStack(spacing: 8) {
                ForEach(dependentTodos) { dependentTodo in
                    HStack {
                        Image(systemName: dependentTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(dependentTodo.isCompleted ? .green : .orange)
                        
                        Text(dependentTodo.title)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            
            if !allDependenciesMet {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("需要先完成依赖任务")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var dependentTodos: [TodoItem] {
        todos.filter { todo.dependencies.contains($0.id) }
    }
    
    private var allDependenciesMet: Bool {
        dependentTodos.allSatisfy { $0.isCompleted }
    }
}

struct RecurrenceSection: View {
    let rule: RecurrenceRule?
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("重复规则")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                Button(rule == nil ? "设置" : "编辑", action: onEdit)
            }
            
            if let rule = rule {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                        Text(ruleDescription(rule))
                            .font(.subheadline)
                    }
                    
                    if let nextDate = rule.nextOccurrence(after: Date()) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.secondary)
                            Text("下次: \(formatDate(nextDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("这是一次性任务")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func ruleDescription(_ rule: RecurrenceRule) -> String {
        var desc = "每"
        if rule.interval > 1 {
            desc += "\(rule.interval)"
        }
        desc += rule.frequency.rawValue
        
        switch rule.endType {
        case .never:
            desc += "，永久重复"
        case .onDate:
            if let date = rule.endDate {
                desc += "，直到\(formatDate(date))"
            }
        case .afterCount:
            if let count = rule.occurrenceCount {
                desc += "，共\(count)次"
            }
        }
        
        return desc
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CommentsSection: View {
    let comments: [TaskComment]
    let onAddComment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("评论")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                Button(action: onAddComment) {
                    Image(systemName: "plus.bubble")
                }
            }
            
            if comments.isEmpty {
                Text("暂无评论")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(comments.sorted { $0.createdDate > $1.createdDate }) { comment in
                        CommentRow(comment: comment)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct CommentRow: View {
    let comment: TaskComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(comment.content)
                .font(.subheadline)
            
            HStack {
                Text(formatDate(comment.createdDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if comment.attachmentType != nil {
                    Image(systemName: attachmentIcon)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var attachmentIcon: String {
        switch comment.attachmentType {
        case .image: return "photo"
        case .audio: return "waveform"
        case .file: return "doc"
        case .none: return ""
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TaskTagsSection: View {
    @Bindable var todo: TodoItem
    @State private var newTag = ""
    @State private var showAddTag = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("标签")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                Button(action: { showAddTag.toggle() }) {
                    Image(systemName: "plus.circle")
                }
            }
            
            if todo.tags.isEmpty && !showAddTag {
                Text("添加标签以便分类和搜索")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(todo.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                            
                            Button(action: {
                                var tags = todo.tags
                                tags.removeAll { $0 == tag }
                                todo.tags = tags
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.todoGradient.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
            }
            
            if showAddTag {
                HStack {
                    TextField("新标签", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("添加") {
                        if !newTag.isEmpty {
                            var tags = todo.tags
                            tags.append(newTag)
                            todo.tags = tags
                            newTag = ""
                            showAddTag = false
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct PomodoroStatsCard: View {
    let completed: Int
    let estimated: Int
    
    var body: some View {
        HStack(spacing: Theme.spacing.xlarge) {
            VStack(alignment: .leading, spacing: 4) {
                Text("番茄钟")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .foregroundStyle(Theme.pomodoroGradient)
                    Text("\(completed) / \(estimated)")
                        .font(.title3.bold())
                }
            }
            
            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.pomodoroGradient)
                        .frame(width: min(geo.size.width * CGFloat(completed) / CGFloat(max(estimated, 1)), geo.size.width))
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct TimeTrackingCard: View {
    let created: Date
    let completed: Date?
    let estimated: Int
    let actual: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("时间记录")
                .font(Theme.headlineFont)
            
            VStack(spacing: 8) {
                TimeRow(icon: "plus.circle", title: "创建时间", value: formatDate(created))
                
                if let completedDate = completed {
                    TimeRow(icon: "checkmark.circle", title: "完成时间", value: formatDate(completedDate))
                    
                    let duration = Int(completedDate.timeIntervalSince(created) / 60)
                    TimeRow(icon: "clock", title: "总用时", value: "\(duration)分钟")
                }
                
                TimeRow(icon: "timer", title: "预估时长", value: "\(estimated)分钟")
                
                if actual > 0 {
                    TimeRow(icon: "stopwatch", title: "实际时长", value: "\(actual)分钟")
                    
                    let accuracy = Double(actual) / Double(estimated)
                    let accuracyText = accuracy <= 1.2 ? "准确" : accuracy <= 1.5 ? "偏长" : "严重超时"
                    TimeRow(icon: "chart.bar", title: "估算准确度", value: accuracyText)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TimeRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption.bold())
        }
    }
}

struct AddCommentView: View {
    @Bindable var todo: TodoItem
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var commentText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $commentText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(height: 200)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("添加评论")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let comment = TaskComment(content: commentText)
                        context.insert(comment)
                        todo.comments.append(comment)
                        dismiss()
                        HapticManager.shared.success()
                    }
                    .disabled(commentText.isEmpty)
                }
            }
        }
    }
}

