//
//  ExamView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  考试管理视图
//

import SwiftUI
import SwiftData

struct ExamView: View {
    @Query(sort: \Exam.examDate) private var exams: [Exam]
    @State private var showAddExam = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 即将到来的考试
                if !upcomingExams.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("即将到来")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        ForEach(upcomingExams) { exam in
                            ExamCard(exam: exam)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 已完成的考试
                if !pastExams.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("历史考试")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        ForEach(pastExams) { exam in
                            ExamCard(exam: exam)
                        }
                        .padding(.horizontal)
                    }
                }
                
                if exams.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("还没有考试记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 100)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("考试管理")
        .toolbar {
            Button(action: { showAddExam = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddExam) {
            AddExamView()
        }
    }
    
    private var upcomingExams: [Exam] {
        exams.filter { !$0.isFinished }
    }
    
    private var pastExams: [Exam] {
        exams.filter { $0.isFinished }
    }
}

struct ExamCard: View {
    let exam: Exam
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(exam.examName)
                    .font(.headline)
                
                HStack {
                    Text(exam.subject)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: Theme.subjectColors[exam.subject] ?? "#94A3B8").opacity(0.2))
                        .foregroundColor(Color(hex: Theme.subjectColors[exam.subject] ?? "#94A3B8"))
                        .clipShape(Capsule())
                    
                    Text(exam.examType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(exam.examDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !exam.isFinished {
                VStack {
                    Text("\(exam.daysRemaining())")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.examGradient)
                    Text("天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let score = exam.scorePercentage {
                VStack {
                    Text(String(format: "%.0f", score))
                        .font(.largeTitle.bold())
                        .foregroundColor(scoreColor(score))
                    Text("分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 90 { return .green }
        if score >= 75 { return .blue }
        if score >= 60 { return .orange }
        return .red
    }
}

struct AddExamView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var examName = ""
    @State private var subject = ""
    @State private var examDate = Date()
    @State private var examType: Exam.ExamType = .mock
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("考试名称", text: $examName)
                TextField("科目", text: $subject)
                DatePicker("考试日期", selection: $examDate, displayedComponents: [.date])
                Picker("考试类型", selection: $examType) {
                    ForEach(Exam.ExamType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            .navigationTitle("添加考试")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let exam = Exam(examName: examName, subject: subject, examDate: examDate, examType: examType)
                        context.insert(exam)
                        dismiss()
                    }
                    .disabled(examName.isEmpty || subject.isEmpty)
                }
            }
        }
    }
}

