//
//  AddGoalView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var goalDescription = ""
    @State private var timeframe: Goal.Timeframe = .quarterly
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!
    @State private var selectedColor = "#A78BFA"
    @State private var keyResults: [TempKeyResult] = []
    
    let colors = ["#A78BFA", "#FF6B6B", "#4ECDC4", "#FFD93D", "#4A90E2", "#FB923C"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("目标信息") {
                    TextField("目标标题", text: $title)
                    TextEditor(text: $goalDescription)
                        .frame(minHeight: 80)
                }
                
                Section("时间范围") {
                    Picker("时间范围", selection: $timeframe) {
                        ForEach([Goal.Timeframe.monthly, .quarterly, .yearly], id: \.self) { tf in
                            Text(tf.rawValue).tag(tf)
                        }
                    }
                    .onChange(of: timeframe) { oldValue, newValue in
                        updateEndDate(for: newValue)
                    }
                    
                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                }
                
                Section("关键结果（可选）") {
                    ForEach(keyResults.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("关键结果", text: $keyResults[index].title)
                            HStack {
                                TextField("目标值", value: $keyResults[index].targetValue, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80)
                                TextField("单位", text: $keyResults[index].unit)
                                    .frame(width: 60)
                            }
                        }
                    }
                    .onDelete(perform: deleteKeyResult)
                    
                    Button(action: addKeyResult) {
                        Label("添加关键结果", systemImage: "plus.circle")
                    }
                }
                
                Section("颜色") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("新建目标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        saveGoal()
                    }
                    .disabled(title.isBlank)
                }
            }
        }
    }
    
    private func updateEndDate(for timeframe: Goal.Timeframe) {
        switch timeframe {
        case .monthly:
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        case .quarterly:
            endDate = Calendar.current.date(byAdding: .month, value: 3, to: startDate)!
        case .yearly:
            endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        }
    }
    
    private func addKeyResult() {
        keyResults.append(TempKeyResult())
    }
    
    private func deleteKeyResult(at offsets: IndexSet) {
        keyResults.remove(atOffsets: offsets)
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            goalDescription: goalDescription,
            timeframe: timeframe,
            startDate: startDate,
            endDate: endDate,
            colorHex: selectedColor
        )
        
        // 添加关键结果
        for tempKR in keyResults where !tempKR.title.isEmpty {
            let kr = KeyResult(
                title: tempKR.title,
                targetValue: tempKR.targetValue,
                unit: tempKR.unit
            )
            modelContext.insert(kr)
            goal.keyResults.append(kr)
        }
        
        modelContext.insert(goal)
        try? modelContext.save()
        dismiss()
    }
}

struct TempKeyResult: Identifiable {
    let id = UUID()
    var title = ""
    var targetValue: Double = 0
    var unit = ""
}

#Preview {
    AddGoalView()
        .modelContainer(for: Goal.self, inMemory: true)
}

