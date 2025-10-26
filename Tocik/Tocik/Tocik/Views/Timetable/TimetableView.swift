//
//  TimetableView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct TimetableView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [CourseItem]
    
    @State private var showingAddCourse = false
    @State private var selectedCourse: CourseItem?
    
    let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    let timeSlots = stride(from: 8, to: 22, by: 1).map { $0 }
    
    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    // 星期标题行
                    HStack(spacing: 0) {
                        // 左上角空白
                        Text("时间")
                            .font(Theme.captionFont)
                            .frame(width: 60, height: 40)
                            .background(Color(.systemGray6))
                        
                        ForEach(1...7, id: \.self) { day in
                            Text(weekdays[day - 1])
                                .font(Theme.bodyFont)
                                .frame(width: 100, height: 40)
                                .background(Color(.systemGray6))
                        }
                    }
                    
                    // 课程网格
                    ForEach(timeSlots, id: \.self) { hour in
                        HStack(spacing: 0) {
                            // 时间列
                            Text(String(format: "%02d:00", hour))
                                .font(Theme.captionFont)
                                .frame(width: 60, height: 80)
                                .background(Color(.systemGray6))
                            
                            // 课程格子
                            ForEach(1...7, id: \.self) { day in
                                ZStack {
                                    Rectangle()
                                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                                        .background(Color(.systemBackground))
                                    
                                    // 显示该时间段的课程
                                    if let course = courseAt(weekday: day, hour: hour) {
                                        CourseCard(course: course)
                                            .onTapGesture {
                                                selectedCourse = course
                                            }
                                    }
                                }
                                .frame(width: 100, height: 80)
                            }
                        }
                    }
                }
            }
            .navigationTitle("课程表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.courseColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(course: course)
            }
        }
    }
    
    private func courseAt(weekday: Int, hour: Int) -> CourseItem? {
        courses.first { course in
            course.weekday == weekday &&
            Calendar.current.component(.hour, from: course.startTime) == hour
        }
    }
}

struct CourseCard: View {
    let course: CourseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(course.courseName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
            
            if !course.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 9))
                    Text(course.location)
                        .font(.system(size: 10))
                }
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            }
            
            Spacer()
            
            Text(timeRange(from: course.startTime, to: course.endTime))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: course.colorHex),
                    Color(hex: course.colorHex).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color(hex: course.colorHex).opacity(0.4), radius: 8, x: 0, y: 4)
        .padding(3)
    }
    
    private func timeRange(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }
}

#Preview {
    TimetableView()
        .modelContainer(for: CourseItem.self, inMemory: true)
}

