//
//  NotificationSettingsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 通知设置
//

import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("enablePomodoroNotif") private var enablePomodoroNotif = true
    @AppStorage("enableTodoNotif") private var enableTodoNotif = true
    @AppStorage("enableCourseNotif") private var enableCourseNotif = true
    @AppStorage("enableEventNotif") private var enableEventNotif = true
    @AppStorage("enableHabitNotif") private var enableHabitNotif = true
    @AppStorage("enableReviewNotif") private var enableReviewNotif = true
    @AppStorage("enableGoalNotif") private var enableGoalNotif = true
    @AppStorage("enableBudgetNotif") private var enableBudgetNotif = true
    
    @AppStorage("notifSound") private var notifSound: NotificationSound = .default
    @AppStorage("quietHoursEnabled") private var quietHoursEnabled = false
    @AppStorage("quietStartTime") private var quietStartHour = 22
    @AppStorage("quietEndTime") private var quietEndHour = 7
    
    enum NotificationSound: String, CaseIterable {
        case `default` = "默认"
        case gentle = "轻柔"
        case alert = "提醒"
        case chime = "铃声"
        case none = "无声"
    }
    
    var body: some View {
        List {
            // 功能通知开关
            Section {
                NotificationToggle(
                    title: "番茄钟",
                    description: "完成时通知",
                    icon: "timer",
                    color: Theme.pomodoroColor,
                    isEnabled: $enablePomodoroNotif
                )
                
                NotificationToggle(
                    title: "待办事项",
                    description: "截止日期提醒",
                    icon: "checkmark.circle",
                    color: Theme.todoColor,
                    isEnabled: $enableTodoNotif
                )
                
                NotificationToggle(
                    title: "课程表",
                    description: "上课前提醒",
                    icon: "book",
                    color: Theme.courseColor,
                    isEnabled: $enableCourseNotif
                )
                
                NotificationToggle(
                    title: "日历事件",
                    description: "事件开始前提醒",
                    icon: "calendar",
                    color: Theme.calendarColor,
                    isEnabled: $enableEventNotif
                )
                
                NotificationToggle(
                    title: "习惯打卡",
                    description: "每日提醒",
                    icon: "star",
                    color: Theme.habitColor,
                    isEnabled: $enableHabitNotif
                )
                
                NotificationToggle(
                    title: "复习提醒",
                    description: "错题和闪卡复习",
                    icon: "brain",
                    color: .purple,
                    isEnabled: $enableReviewNotif
                )
                
                NotificationToggle(
                    title: "目标进度",
                    description: "目标更新提醒",
                    icon: "target",
                    color: Color(hex: "#F59E0B"),
                    isEnabled: $enableGoalNotif
                )
                
                NotificationToggle(
                    title: "预算预警",
                    description: "超支提醒",
                    icon: "dollarsign.circle",
                    color: .green,
                    isEnabled: $enableBudgetNotif
                )
            } header: {
                Text("功能通知")
            }
            
            // 通知声音
            Section {
                Picker("通知声音", selection: $notifSound) {
                    ForEach(NotificationSound.allCases, id: \.self) { sound in
                        Text(sound.rawValue).tag(sound)
                    }
                }
            } header: {
                Text("声音")
            }
            
            // 免打扰时段
            Section {
                Toggle("启用免打扰", isOn: $quietHoursEnabled)
                
                if quietHoursEnabled {
                    HStack {
                        Text("开始时间")
                        Spacer()
                        Picker("", selection: $quietStartHour) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("结束时间")
                        Spacer()
                        Picker("", selection: $quietEndHour) {
                            ForEach(0..<24) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .labelsHidden()
                    }
                }
            } header: {
                Text("免打扰时段")
            } footer: {
                if quietHoursEnabled {
                    Text("在\(String(format: "%02d:00", quietStartHour)) - \(String(format: "%02d:00", quietEndHour))期间不会收到通知")
                }
            }
        }
        .navigationTitle("通知设置")
    }
}

struct NotificationToggle: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isEnabled: Bool
    
    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

