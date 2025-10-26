//
//  AddCourseView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddCourseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var courseName = ""
    @State private var teacher = ""
    @State private var location = ""
    @State private var weekday = 1
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 10, minute: 40))!
    @State private var selectedColor = "#4A90E2"
    @State private var notifyMinutes = 10
    
    let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    let colors = ["#4A90E2", "#FF6B6B", "#4ECDC4", "#FFD93D", "#95E1D3", "#A78BFA", "#FB923C"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("课程信息") {
                    TextField("课程名称", text: $courseName)
                    TextField("教师", text: $teacher)
                    TextField("地点", text: $location)
                }
                
                Section("时间安排") {
                    Picker("星期", selection: $weekday) {
                        ForEach(1...7, id: \.self) { day in
                            Text(weekdays[day - 1]).tag(day)
                        }
                    }
                    
                    DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)
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
                
                Section("提醒") {
                    Picker("提前提醒", selection: $notifyMinutes) {
                        Text("不提醒").tag(0)
                        Text("5分钟").tag(5)
                        Text("10分钟").tag(10)
                        Text("15分钟").tag(15)
                        Text("30分钟").tag(30)
                    }
                }
            }
            .navigationTitle("添加课程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCourse()
                    }
                    .disabled(courseName.isBlank)
                }
            }
        }
    }
    
    private func saveCourse() {
        let course = CourseItem(
            courseName: courseName,
            location: location,
            teacher: teacher,
            weekday: weekday,
            startTime: startTime,
            endTime: endTime,
            colorHex: selectedColor,
            notifyMinutesBefore: notifyMinutes
        )
        
        modelContext.insert(course)
        try? modelContext.save()
        
        // 设置课程提醒
        if notifyMinutes > 0 {
            notificationManager.scheduleCourseNotification(
                courseId: course.id,
                courseName: courseName,
                location: location,
                startTime: startTime,
                minutesBefore: notifyMinutes
            )
        }
        
        dismiss()
    }
}

#Preview {
    AddCourseView()
        .modelContainer(for: CourseItem.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}

