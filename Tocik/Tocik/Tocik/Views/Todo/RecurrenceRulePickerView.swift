//
//  RecurrenceRulePickerView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 重复规则选择器
//

import SwiftUI
import SwiftData

struct RecurrenceRulePickerView: View {
    @Binding var recurrenceRule: RecurrenceRule?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var frequency: RecurrenceRule.Frequency = .daily
    @State private var interval: Int = 1
    @State private var selectedWeekdays: Set<Int> = []
    @State private var endType: RecurrenceRule.EndType = .never
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 30)
    @State private var occurrenceCount: Int = 10
    
    let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        NavigationStack {
            Form {
                // 频率选择
                Section("重复频率") {
                    Picker("频率", selection: $frequency) {
                        Text("每天").tag(RecurrenceRule.Frequency.daily)
                        Text("每周").tag(RecurrenceRule.Frequency.weekly)
                        Text("每月").tag(RecurrenceRule.Frequency.monthly)
                        Text("每年").tag(RecurrenceRule.Frequency.yearly)
                    }
                    
                    Stepper("每 \(interval) \(frequencyUnit)", value: $interval, in: 1...30)
                }
                
                // 每周重复时选择星期几
                if frequency == .weekly {
                    Section("重复日期") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(1...7, id: \.self) { day in
                                Button(action: {
                                    if selectedWeekdays.contains(day) {
                                        selectedWeekdays.remove(day)
                                    } else {
                                        selectedWeekdays.insert(day)
                                    }
                                    HapticManager.shared.light()
                                }) {
                                    Text(weekdays[day == 7 ? 0 : day])
                                        .font(.caption)
                                        .frame(width: 36, height: 36)
                                        .background(selectedWeekdays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedWeekdays.contains(day) ? .white : .primary)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // 结束条件
                Section("结束重复") {
                    Picker("结束方式", selection: $endType) {
                        Text("永不结束").tag(RecurrenceRule.EndType.never)
                        Text("在日期").tag(RecurrenceRule.EndType.onDate)
                        Text("重复次数后").tag(RecurrenceRule.EndType.afterCount)
                    }
                    
                    if endType == .onDate {
                        DatePicker("结束日期", selection: $endDate, displayedComponents: .date)
                    } else if endType == .afterCount {
                        Stepper("重复 \(occurrenceCount) 次", value: $occurrenceCount, in: 1...365)
                    }
                }
                
                // 预览
                Section("预览") {
                    Text(previewText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(recurrenceRule == nil ? "设置重复" : "编辑重复")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        saveRule()
                        dismiss()
                    }
                    .disabled(frequency == .weekly && selectedWeekdays.isEmpty)
                }
            }
            .onAppear {
                loadExistingRule()
            }
        }
    }
    
    private var frequencyUnit: String {
        switch frequency {
        case .daily: return "天"
        case .weekly: return "周"
        case .monthly: return "月"
        case .yearly: return "年"
        }
    }
    
    private var previewText: String {
        var text = "每"
        if interval > 1 {
            text += "\(interval)"
        }
        text += frequencyUnit
        
        if frequency == .weekly && !selectedWeekdays.isEmpty {
            let days = selectedWeekdays.sorted().map { weekdays[$0 == 7 ? 0 : $0] }
            text += "的" + days.joined(separator: "、")
        }
        
        text += "重复"
        
        switch endType {
        case .never:
            text += "，永不结束"
        case .onDate:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            text += "，直到\(formatter.string(from: endDate))"
        case .afterCount:
            text += "，共\(occurrenceCount)次"
        }
        
        return text
    }
    
    private func loadExistingRule() {
        if let rule = recurrenceRule {
            frequency = rule.frequency
            interval = rule.interval
            selectedWeekdays = Set(rule.daysOfWeek)
            endType = rule.endType
            if let date = rule.endDate {
                endDate = date
            }
            if let count = rule.occurrenceCount {
                occurrenceCount = count
            }
        }
    }
    
    private func saveRule() {
        let rule = RecurrenceRule(
            frequency: frequency,
            interval: interval,
            daysOfWeek: Array(selectedWeekdays),
            endType: endType
        )
        
        if endType == .onDate {
            rule.endDate = endDate
        } else if endType == .afterCount {
            rule.occurrenceCount = occurrenceCount
        }
        
        context.insert(rule)
        recurrenceRule = rule
        HapticManager.shared.success()
    }
}

