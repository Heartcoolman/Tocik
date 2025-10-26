//
//  CourseDetailView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct CourseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query private var notes: [Note]
    
    let course: CourseItem
    
    let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    @State private var showingNotes = false
    @State private var showingAddNote = false
    
    var courseNotes: [Note] {
        notes.filter { $0.relatedCourseId == course.id }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("课程笔记") {
                    HStack {
                        Label("\(courseNotes.count) 篇笔记", systemImage: "note.text")
                        
                        Spacer()
                        
                        Button("查看") {
                            showingNotes = true
                        }
                    }
                    
                    Button(action: { showingAddNote = true }) {
                        Label("创建课程笔记", systemImage: "plus.circle")
                    }
                }
                
                Divider()
                
                Section {
                    HStack {
                        Text("课程名称")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(course.courseName)
                    }
                    
                    if !course.teacher.isEmpty {
                        HStack {
                            Text("教师")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(course.teacher)
                        }
                    }
                    
                    if !course.location.isEmpty {
                        HStack {
                            Text("地点")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(course.location)
                        }
                    }
                }
                
                Section("时间") {
                    HStack {
                        Text("星期")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(weekdays[course.weekday - 1])
                    }
                    
                    HStack {
                        Text("上课时间")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(timeRange(from: course.startTime, to: course.endTime))
                    }
                }
                
                Section {
                    Button(role: .destructive, action: deleteCourse) {
                        HStack {
                            Spacer()
                            Text("删除课程")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("课程详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNotes) {
                CourseNotesView(courseId: course.id, courseName: course.courseName)
            }
            .sheet(isPresented: $showingAddNote) {
                EditNoteView(note: nil, relatedCourseId: course.id, courseName: course.courseName)
            }
        }
    }
    
    private func timeRange(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func deleteCourse() {
        notificationManager.removeCourseNotifications(courseId: course.id)
        modelContext.delete(course)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CourseItem.self, configurations: config)
    
    let course = CourseItem(
        courseName: "高等数学",
        location: "教学楼A101",
        teacher: "张老师",
        weekday: 1,
        startTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        endTime: Calendar.current.date(from: DateComponents(hour: 10, minute: 40))!
    )
    
    return CourseDetailView(course: course)
        .modelContainer(container)
        .environmentObject(NotificationManager.shared)
}

