//
//  SubjectView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  科目管理视图
//

import SwiftUI
import SwiftData

struct SubjectView: View {
    @Query private var subjects: [Subject]
    @State private var showAddSubject = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(subjects) { subject in
                    SubjectGridCard(subject: subject)
                }
                
                // 添加科目按钮
                Button(action: { showAddSubject = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Theme.primaryGradient)
                        Text("添加科目")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle("科目管理")
        .sheet(isPresented: $showAddSubject) {
            AddSubjectView()
        }
    }
}

struct SubjectGridCard: View {
    let subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subject.icon)
                    .font(.title)
                    .foregroundColor(Color(hex: subject.colorHex))
                Spacer()
                Text(subject.difficulty.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Text(subject.name)
                .font(.title3.bold())
            
            HStack(spacing: 16) {
                StatItem(label: "笔记", value: "\(subject.totalNotes)")
                StatItem(label: "闪卡", value: "\(subject.totalFlashCards)")
                StatItem(label: "错题", value: "\(subject.totalWrongQuestions)")
            }
            .font(.caption)
            
            HStack {
                Text(String(format: "%.1fh", subject.totalStudyHours))
                    .font(.headline)
                    .foregroundColor(Color(hex: subject.colorHex))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .background(Color(hex: subject.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: subject.colorHex).opacity(0.3), lineWidth: 2)
        )
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct AddSubjectView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var teacher = ""
    @State private var difficulty: Subject.Difficulty = .medium
    @State private var selectedColor = "#667EEA"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("科目名称", text: $name)
                TextField("教师（可选）", text: $teacher)
                Picker("难度", selection: $difficulty) {
                    ForEach(Subject.Difficulty.allCases, id: \.self) { diff in
                        Text(diff.rawValue).tag(diff)
                    }
                }
            }
            .navigationTitle("添加科目")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let subject = Subject(
                            name: name,
                            colorHex: Theme.subjectColors[name],
                            difficulty: difficulty,
                            teacher: teacher.isEmpty ? nil : teacher
                        )
                        context.insert(subject)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct SubjectDetailView: View {
    @Bindable var subject: Subject
    @Query private var notes: [Note]
    @Query private var flashCards: [FlashCard]
    @Query private var wrongQuestions: [WrongQuestion]
    
    var subjectNotes: [Note] {
        notes.filter { $0.category == subject.name }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 科目信息
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: subject.icon)
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: subject.colorHex))
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(subject.difficulty.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Capsule())
                            
                            if let teacher = subject.teacher {
                                Text(teacher)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text(subject.name)
                        .font(.largeTitle.bold())
                    
                    // 统计网格
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        SubjectStatCard(label: "学习时长", value: String(format: "%.1fh", subject.totalStudyHours), color: Color(hex: subject.colorHex))
                        SubjectStatCard(label: "番茄钟", value: "\(subject.totalPomodoroSessions)", color: Color(hex: subject.colorHex))
                        SubjectStatCard(label: "笔记", value: "\(subject.totalNotes)", color: Color(hex: subject.colorHex))
                        SubjectStatCard(label: "闪卡", value: "\(subject.totalFlashCards)", color: Color(hex: subject.colorHex))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // 相关笔记
                if !subjectNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("相关笔记")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(subjectNotes.prefix(5)) { note in
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.subheadline.bold())
                                Text(note.createdDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(subject.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubjectStatCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
