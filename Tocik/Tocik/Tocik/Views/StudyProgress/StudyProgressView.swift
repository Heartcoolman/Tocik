//
//  StudyProgressView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData
import Charts

struct StudyProgressView: View {
    @Query private var courses: [CourseItem]
    @Query private var notes: [Note]
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var flashDecks: [FlashDeck]
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case all = "全部"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择
                    Picker("时间范围", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 总览卡片
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ProgressCard(
                            title: "学习时长",
                            value: "\(studyHours)",
                            subtitle: "小时",
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        ProgressCard(
                            title: "笔记数量",
                            value: "\(filteredNotes.count)",
                            subtitle: "篇",
                            icon: "note.text",
                            color: .purple
                        )
                        
                        ProgressCard(
                            title: "错题数量",
                            value: "\(filteredWrongQuestions.count)",
                            subtitle: "道",
                            icon: "exclamationmark.triangle",
                            color: .red
                        )
                        
                        ProgressCard(
                            title: "闪卡复习",
                            value: "\(reviewedCards)",
                            subtitle: "张",
                            icon: "rectangle.stack",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // 科目学习时长
                    if !courses.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("各科目学习分布")
                                .font(Theme.headlineFont)
                                .padding(.horizontal)
                            
                            ForEach(courses) { course in
                                SubjectProgressRow(
                                    courseName: course.courseName,
                                    noteCount: notes.filter { $0.relatedCourseId == course.id }.count,
                                    wrongCount: wrongQuestions.filter { $0.subject == course.courseName }.count,
                                    color: Color(hex: course.colorHex)
                                )
                            }
                        }
                    }
                    
                    // 学习趋势
                    if #available(iOS 16.0, *) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("学习时长趋势")
                                .font(Theme.headlineFont)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(last7DaysStudyTime(), id: \.day) { data in
                                    BarMark(
                                        x: .value("日期", data.day),
                                        y: .value("时长", data.minutes)
                                    )
                                    .foregroundStyle(Theme.primaryGradient)
                                    .cornerRadius(4)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(Theme.cornerRadius)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("学习进度")
        }
    }
    
    private var filteredNotes: [Note] {
        notes.filter { note in
            switch selectedTimeRange {
            case .week:
                return note.createdDate.isThisWeek
            case .month:
                return Calendar.current.isDate(note.createdDate, equalTo: Date(), toGranularity: .month)
            case .all:
                return true
            }
        }
    }
    
    private var filteredWrongQuestions: [WrongQuestion] {
        wrongQuestions.filter { q in
            switch selectedTimeRange {
            case .week:
                return q.createdDate.isThisWeek
            case .month:
                return Calendar.current.isDate(q.createdDate, equalTo: Date(), toGranularity: .month)
            case .all:
                return true
            }
        }
    }
    
    private var studyHours: Int {
        let sessions = pomodoroSessions.filter { session in
            session.sessionType == .work && session.isCompleted
        }
        
        let filtered = sessions.filter { session in
            switch selectedTimeRange {
            case .week:
                return session.startTime.isThisWeek
            case .month:
                return Calendar.current.isDate(session.startTime, equalTo: Date(), toGranularity: .month)
            case .all:
                return true
            }
        }
        
        return filtered.count * 25 / 60 // 每个番茄钟25分钟
    }
    
    private var reviewedCards: Int {
        var total = 0
        for deck in flashDecks {
            total += deck.cards.filter { $0.reviewCount > 0 }.count
        }
        return total
    }
    
    private func last7DaysStudyTime() -> [(day: String, minutes: Int)] {
        (0..<7).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -6 + i, to: Date())!
            let dayName = date.formatted("E")
            let sessions = pomodoroSessions.filter {
                $0.sessionType == .work &&
                $0.isCompleted &&
                Calendar.current.isDate($0.startTime, inSameDayAs: date)
            }
            return (dayName, sessions.count * 25)
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
    }
}

struct SubjectProgressRow: View {
    let courseName: String
    let noteCount: Int
    let wrongCount: Int
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(courseName)
                    .font(Theme.bodyFont)
                
                HStack(spacing: 16) {
                    Label("\(noteCount) 笔记", systemImage: "note.text")
                        .font(.caption)
                    Label("\(wrongCount) 错题", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.smallCornerRadius)
        .padding(.horizontal)
    }
}

#Preview {
    StudyProgressView()
        .modelContainer(for: [CourseItem.self, Note.self, WrongQuestion.self, PomodoroSession.self], inMemory: true)
}

