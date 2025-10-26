//
//  WrongQuestionView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct WrongQuestionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WrongQuestion.createdDate, order: .reverse) private var questions: [WrongQuestion]
    
    @State private var showingAddQuestion = false
    @State private var selectedSubject: String?
    
    var subjects: [String] {
        Array(Set(questions.map { $0.subject })).sorted()
    }
    
    var filteredQuestions: [WrongQuestion] {
        if let subject = selectedSubject {
            return questions.filter { $0.subject == subject }
        }
        return questions
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if questions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("记录您的第一道错题")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(filteredQuestions) { question in
                            WrongQuestionRow(question: question)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        modelContext.delete(question)
                                        try? modelContext.save()
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("错题本")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { selectedSubject = nil }) {
                            Label("全部科目", systemImage: selectedSubject == nil ? "checkmark" : "")
                        }
                        
                        ForEach(subjects, id: \.self) { subject in
                            Button(action: { selectedSubject = subject }) {
                                Label(subject, systemImage: selectedSubject == subject ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddQuestion = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddQuestion) {
                AddWrongQuestionView()
            }
        }
    }
}

struct WrongQuestionRow: View {
    let question: WrongQuestion
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 12) {
                // 题目图片缩略图
                if let imageData = question.questionImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.subject)
                        .font(Theme.bodyFont)
                    
                    HStack {
                        Label(question.masteryLevel.displayName, systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color(hex: question.masteryLevel.colorHex))
                        
                        Text("复习\(question.reviewCount)次")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !question.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(question.tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingDetail) {
            WrongQuestionDetailView(question: question)
        }
    }
}

#Preview {
    WrongQuestionView()
        .modelContainer(for: WrongQuestion.self, inMemory: true)
}

