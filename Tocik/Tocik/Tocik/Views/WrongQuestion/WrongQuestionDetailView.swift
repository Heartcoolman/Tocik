//
//  WrongQuestionDetailView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct WrongQuestionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let question: WrongQuestion
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 题目图片
                    if let imageData = question.questionImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                    
                    // 科目和状态
                    HStack {
                        Text(question.subject)
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        Menu {
                            ForEach(WrongQuestion.MasteryLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    question.masteryLevel = level
                                    if level == .mastered {
                                        question.reviewCount += 1
                                    }
                                    question.lastReviewDate = Date()
                                    try? modelContext.save()
                                }) {
                                    Label(level.displayName, systemImage: question.masteryLevel == level ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Text(question.masteryLevel.displayName)
                                .font(Theme.bodyFont)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: question.masteryLevel.colorHex).opacity(0.2))
                                .foregroundColor(Color(hex: question.masteryLevel.colorHex))
                                .cornerRadius(8)
                        }
                    }
                    
                    // 解析
                    if !question.analysis.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("解析")
                                .font(Theme.headlineFont)
                            
                            Text(question.analysis)
                                .font(Theme.bodyFont)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // 笔记
                    if !question.note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("笔记")
                                .font(Theme.headlineFont)
                            
                            Text(question.note)
                                .font(Theme.bodyFont)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // 统计信息
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(question.reviewCount)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.blue)
                            Text("复习次数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let lastReview = question.lastReviewDate {
                            VStack {
                                Text(lastReview.timeAgoDisplay())
                                    .font(Theme.bodyFont)
                                    .foregroundColor(.blue)
                                Text("上次复习")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("错题详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WrongQuestion.self, configurations: config)
    
    let question = WrongQuestion(subject: "数学", analysis: "这是解析内容")
    
    return WrongQuestionDetailView(question: question)
        .modelContainer(container)
}

