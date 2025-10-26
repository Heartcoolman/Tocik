//
//  StudyJournalView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  学习日志视图
//

import SwiftUI
import SwiftData

struct StudyJournalView: View {
    @Query(sort: \StudyJournal.date, order: .reverse) private var journals: [StudyJournal]
    @State private var showAddJournal = false
    @State private var selectedJournal: StudyJournal?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(journals) { journal in
                    JournalCard(journal: journal)
                        .onTapGesture {
                            selectedJournal = journal
                        }
                }
                
                if journals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Theme.primaryGradient)
                        Text("开始记录你的学习日志")
                            .font(.title2.bold())
                        Text("记录每天的学习心得和感悟")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showAddJournal = true }) {
                            Text("写第一篇日志")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 300)
                                .background(Theme.primaryGradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 100)
                }
            }
            .padding()
        }
        .navigationTitle("学习日志")
        .toolbar {
            Button(action: { showAddJournal = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddJournal) {
            AddJournalView()
        }
        .sheet(item: $selectedJournal) { journal in
            JournalDetailView(journal: journal)
        }
    }
}

struct JournalCard: View {
    let journal: StudyJournal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(journal.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Text(journal.mood.emoji)
                    .font(.title)
            }
            
            if !journal.highlights.isEmpty {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(journal.highlights)
                        .font(.subheadline)
                        .lineLimit(2)
                }
            }
            
            if !journal.challenges.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(journal.challenges)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Divider()
            
            HStack {
                Label("\(String(format: "%.1f", journal.studyHours))h", systemImage: "clock")
                Spacer()
                Label("\(journal.pomodoroCount)个", systemImage: "timer")
                Spacer()
                Label("\(journal.tasksCompleted)个", systemImage: "checkmark")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AddJournalView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    
    @State private var mood: StudyJournal.Mood = .okay
    @State private var highlights = ""
    @State private var challenges = ""
    @State private var reflections = ""
    @State private var tomorrowPlan = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("今日感受") {
                    Picker("心情", selection: $mood) {
                        ForEach(StudyJournal.Mood.allCases, id: \.self) { m in
                            HStack {
                                Text(m.emoji)
                                Text(m.displayName)
                            }
                            .tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("今日亮点") {
                    TextField("今天有什么收获？", text: $highlights, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("遇到的困难") {
                    TextField("有什么困难或疑问？", text: $challenges, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("反思总结") {
                    TextField("今天学到了什么？", text: $reflections, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("明日计划") {
                    TextField("明天打算做什么？", text: $tomorrowPlan, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("今日数据") {
                    HStack {
                        Text("番茄钟")
                        Spacer()
                        Text("\(todayPomodoroCount)个")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("完成任务")
                        Spacer()
                        Text("\(todayTasksCompleted)个")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("学习时长")
                        Spacer()
                        Text(String(format: "%.1fh", Double(todayPomodoroCount) * 0.5))
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("写日志")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let journal = StudyJournal(mood: mood)
                        journal.highlights = highlights
                        journal.challenges = challenges
                        journal.reflections = reflections
                        journal.tomorrowPlan = tomorrowPlan
                        journal.pomodoroCount = todayPomodoroCount
                        journal.tasksCompleted = todayTasksCompleted
                        journal.studyHours = Double(todayPomodoroCount) * 0.5
                        context.insert(journal)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var todayPomodoroCount: Int {
        pomodoroSessions.filter {
            Calendar.current.isDateInToday($0.startTime) && $0.isCompleted
        }.count
    }
    
    private var todayTasksCompleted: Int {
        todos.filter {
            guard let date = $0.completedDate else { return false }
            return Calendar.current.isDateInToday(date)
        }.count
    }
}

struct JournalDetailView: View {
    @Bindable var journal: StudyJournal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 心情
                    HStack {
                        Text("心情")
                            .font(.headline)
                        Spacer()
                        HStack {
                            Text(journal.mood.emoji)
                                .font(.largeTitle)
                            Text(journal.mood.displayName)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 亮点
                    if !journal.highlights.isEmpty {
                        SectionCard(title: "今日亮点", icon: "star.fill", color: .yellow, content: journal.highlights)
                    }
                    
                    // 困难
                    if !journal.challenges.isEmpty {
                        SectionCard(title: "遇到的困难", icon: "exclamationmark.triangle.fill", color: .orange, content: journal.challenges)
                    }
                    
                    // 反思
                    if !journal.reflections.isEmpty {
                        SectionCard(title: "反思总结", icon: "brain", color: .purple, content: journal.reflections)
                    }
                    
                    // 明日计划
                    if !journal.tomorrowPlan.isEmpty {
                        SectionCard(title: "明日计划", icon: "calendar", color: .blue, content: journal.tomorrowPlan)
                    }
                    
                    // 统计
                    HStack(spacing: 20) {
                        StatBox(title: "学习时长", value: String(format: "%.1fh", journal.studyHours), color: Theme.pomodoroColor)
                        StatBox(title: "番茄钟", value: "\(journal.pomodoroCount)个", color: Theme.primaryColor)
                        StatBox(title: "完成任务", value: "\(journal.tasksCompleted)个", color: Theme.todoColor)
                    }
                }
                .padding()
            }
            .navigationTitle(journal.date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("完成") { dismiss() }
            }
        }
    }
}

struct SectionCard: View {
    let title: String
    let icon: String
    let color: Color
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(color)
            Text(content)
                .font(.subheadline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

