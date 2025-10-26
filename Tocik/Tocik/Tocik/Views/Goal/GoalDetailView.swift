//
//  GoalDetailView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let goal: Goal
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 目标信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text(goal.title)
                            .font(.system(size: 28, weight: .bold))
                        
                        if !goal.goalDescription.isEmpty {
                            Text(goal.goalDescription)
                                .font(Theme.bodyFont)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label(goal.timeframe.rawValue, systemImage: "calendar")
                            Spacer()
                            Text("\(goal.startDate.formatted("yyyy/MM/dd")) - \(goal.endDate.formatted("yyyy/MM/dd"))")
                        }
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(Theme.cornerRadius)
                    
                    // 总体进度
                    VStack(spacing: 12) {
                        Text("总体进度")
                            .font(Theme.headlineFont)
                        
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 20)
                                .opacity(0.2)
                                .foregroundColor(Color(hex: goal.colorHex))
                            
                            Circle()
                                .trim(from: 0.0, to: goal.overallProgress() / 100)
                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .foregroundColor(Color(hex: goal.colorHex))
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.linear, value: goal.overallProgress())
                            
                            Text("\(Int(goal.overallProgress()))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: goal.colorHex))
                        }
                        .frame(width: 200, height: 200)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(Theme.cornerRadius)
                    
                    // 关键结果列表
                    VStack(alignment: .leading, spacing: 12) {
                        Text("关键结果")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        ForEach(goal.keyResults) { kr in
                            KeyResultCard(keyResult: kr, goalColor: Color(hex: goal.colorHex))
                        }
                    }
                    
                    // 操作按钮
                    VStack(spacing: 12) {
                        Button(action: archiveGoal) {
                            Text(goal.isArchived ? "取消归档" : "归档目标")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(Theme.smallCornerRadius)
                        }
                        
                        Button(role: .destructive, action: deleteGoal) {
                            Text("删除目标")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(Theme.smallCornerRadius)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("目标详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func archiveGoal() {
        goal.isArchived.toggle()
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteGoal() {
        modelContext.delete(goal)
        try? modelContext.save()
        dismiss()
    }
}

struct KeyResultCard: View {
    let keyResult: KeyResult
    let goalColor: Color
    
    @State private var isEditing = false
    @State private var editingValue: Double
    
    init(keyResult: KeyResult, goalColor: Color) {
        self.keyResult = keyResult
        self.goalColor = goalColor
        _editingValue = State(initialValue: keyResult.currentValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(keyResult.title)
                    .font(Theme.bodyFont)
                
                Spacer()
                
                if isEditing {
                    HStack(spacing: 4) {
                        TextField("当前值", value: $editingValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .keyboardType(.decimalPad)
                        
                        Text("/ \(Int(keyResult.targetValue))")
                        Text(keyResult.unit)
                    }
                    .font(.caption)
                } else {
                    Text("\(Int(keyResult.currentValue)) / \(Int(keyResult.targetValue)) \(keyResult.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goalColor)
                        .frame(width: geometry.size.width * keyResult.progress / 100)
                }
            }
            .frame(height: 8)
            
            HStack {
                Button(isEditing ? "保存" : "更新进度") {
                    if isEditing {
                        keyResult.currentValue = editingValue
                        keyResult.updateProgress()
                    }
                    isEditing.toggle()
                }
                .font(.caption)
                .foregroundColor(goalColor)
                
                Spacer()
                
                Text("\(Int(keyResult.progress))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.smallCornerRadius)
        .padding(.horizontal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, configurations: config)
    
    let goal = Goal(
        title: "提升编程能力",
        timeframe: .quarterly,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!
    )
    
    return GoalDetailView(goal: goal)
        .modelContainer(container)
}

