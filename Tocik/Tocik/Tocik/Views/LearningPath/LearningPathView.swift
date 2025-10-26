//
//  LearningPathView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 学习路径
//

import SwiftUI
import SwiftData

struct LearningPathView: View {
    @Query private var paths: [LearningPath]
    @Environment(\.modelContext) private var context
    
    @State private var showAddPath = false
    
    var body: some View {
        NavigationStack {
            Group {
                if paths.isEmpty {
                    EmptyPathView(showAddPath: $showAddPath)
                } else {
                    List {
                        ForEach(paths.sorted { $0.createdDate > $1.createdDate }) { path in
                            NavigationLink {
                                LearningPathDetailView(path: path)
                            } label: {
                                LearningPathRow(path: path)
                            }
                        }
                        .onDelete(perform: deletePath)
                    }
                }
            }
            .navigationTitle("学习路径")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddPath = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPath) {
                AddLearningPathView()
            }
        }
    }
    
    private func deletePath(at offsets: IndexSet) {
        for index in offsets {
            let path = paths.sorted { $0.createdDate > $1.createdDate }[index]
            context.delete(path)
        }
    }
}

struct EmptyPathView: View {
    @Binding var showAddPath: Bool
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Image(systemName: "map.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.flashcardGradient)
            
            Text("创建学习路径")
                .font(.title.bold())
            
            Text("规划系统的学习计划\n设定里程碑目标，稳步前进")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showAddPath = true }) {
                Label("创建路径", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Theme.flashcardGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LearningPathRow: View {
    let path: LearningPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(path.name)
                    .font(.headline)
                
                Spacer()
                
                if path.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(path.subject)
                .font(.subheadline)
                .foregroundColor(Color(hex: path.colorHex))
            
            // 进度
            ProgressView(value: path.overallProgress()) {
                HStack {
                    Text("进度: \(Int(path.overallProgress() * 100))%")
                    Spacer()
                    Text("\(completedMilestones)/\(path.milestones.count)个里程碑")
                }
                .font(.caption)
            }
            .tint(Color(hex: path.colorHex))
            
            // 截止日期
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("目标: \(formatDate(path.targetDate))")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var completedMilestones: Int {
        path.milestones.filter { $0.isCompleted }.count
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AddLearningPathView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var subject = ""
    @State private var targetDate = Date().addingTimeInterval(86400 * 90)
    @State private var milestones: [String] = [""]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("路径名称", text: $name)
                    TextField("科目", text: $subject)
                    TextEditor(text: $description)
                        .frame(height: 80)
                    DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
                }
                
                Section("里程碑") {
                    ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                        HStack {
                            TextField("里程碑 \(index + 1)", text: Binding(
                                get: { milestones[index] },
                                set: { milestones[index] = $0 }
                            ))
                            
                            if milestones.count > 1 {
                                Button(action: {
                                    milestones.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: { milestones.append("") }) {
                        Label("添加里程碑", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("创建学习路径")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        savePath()
                    }
                    .disabled(name.isEmpty || subject.isEmpty)
                }
            }
        }
    }
    
    private func savePath() {
        let path = LearningPath(
            name: name,
            pathDescription: description,
            subject: subject,
            targetDate: targetDate
        )
        
        // 添加里程碑
        for (index, milestoneTitle) in milestones.enumerated() where !milestoneTitle.isEmpty {
            let milestone = LearningMilestone(
                title: milestoneTitle,
                orderIndex: index,
                estimatedHours: 10
            )
            path.milestones.append(milestone)
            context.insert(milestone)
        }
        
        context.insert(path)
        dismiss()
        HapticManager.shared.success()
    }
}

struct LearningPathDetailView: View {
    @Bindable var path: LearningPath
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing.large) {
                // 路径信息
                PathInfoCard(path: path)
                
                // 进度可视化
                PathProgressView(path: path)
                
                // 里程碑列表
                MilestonesListView(milestones: path.milestones.sorted { $0.orderIndex < $1.orderIndex })
            }
            .padding()
        }
        .navigationTitle(path.name)
    }
}

struct PathInfoCard: View {
    let path: LearningPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(path.subject)
                .font(.title3.bold())
                .foregroundColor(Color(hex: path.colorHex))
            
            if !path.pathDescription.isEmpty {
                Text(path.pathDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(formatDate(path.targetDate), systemImage: "calendar")
                    .font(.caption)
                
                Spacer()
                
                Text("\(daysRemaining)天剩余")
                    .font(.caption.bold())
                    .foregroundColor(daysRemaining < 30 ? .orange : .blue)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: path.targetDate).day ?? 0
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PathProgressView: View {
    let path: LearningPath
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ProgressRingView(
                    progress: path.overallProgress(),
                    gradient: LinearGradient(
                        colors: [Color(hex: path.colorHex), Color(hex: path.colorHex).opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 20,
                    size: 180
                )
                
                VStack {
                    Text("\(Int(path.overallProgress() * 100))%")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    
                    Text("完成进度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                VStack {
                    Text("\(completedCount)")
                        .font(.title2.bold())
                    Text("已完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("\(path.milestones.count)")
                        .font(.title2.bold())
                    Text("总里程碑")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var completedCount: Int {
        path.milestones.filter { $0.isCompleted }.count
    }
}

struct MilestonesListView: View {
    let milestones: [LearningMilestone]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("里程碑")
                .font(Theme.titleFont)
            
            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                MilestoneRow(milestone: milestone, index: index + 1)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct MilestoneRow: View {
    @Bindable var milestone: LearningMilestone
    let index: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 序号
            ZStack {
                Circle()
                    .fill(milestone.isCompleted ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                
                if milestone.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                } else {
                    Text("\(index)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline.bold())
                    .strikethrough(milestone.isCompleted)
                
                if !milestone.milestoneDescription.isEmpty {
                    Text(milestone.milestoneDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("\(milestone.estimatedHours)h", systemImage: "clock")
                        .font(.caption)
                    
                    if milestone.actualHours > 0 {
                        Text("实际: \(milestone.actualHours)h")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 完成按钮
            Button(action: {
                withAnimation {
                    milestone.isCompleted.toggle()
                    if milestone.isCompleted {
                        milestone.completedDate = Date()
                        HapticManager.shared.pattern(.complete)
                    } else {
                        milestone.completedDate = nil
                    }
                }
            }) {
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(milestone.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 8)
    }
}

