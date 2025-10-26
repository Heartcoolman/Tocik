//
//  SubjectQuickCardsRow.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  科目快捷卡片横向滚动
//

import SwiftUI
import SwiftData

struct SubjectQuickCardsRow: View {
    @Query private var subjects: [Subject]
    @State private var showAddSubject = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我的科目")
                    .font(.title2.bold())
                Spacer()
                Button(action: { showAddSubject = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.primaryGradient)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(subjects) { subject in
                        NavigationLink(value: subject) {
                            SubjectQuickCard(subject: subject)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if subjects.isEmpty {
                        Button(action: { showAddSubject = true }) {
                            AddSubjectPromptCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showAddSubject) {
            AddSubjectView()
        }
    }
}

struct SubjectQuickCard: View {
    let subject: Subject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: subject.icon)
                    .font(.title)
                Spacer()
                Circle()
                    .fill(Color(hex: subject.colorHex))
                    .frame(width: 12, height: 12)
            }
            
            Text(subject.name)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", subject.totalStudyHours))h")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: subject.colorHex))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("笔记")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(subject.totalNotes)")
                        .font(.subheadline.bold())
                }
            }
        }
        .padding()
        .frame(width: 180, height: 140)
        .background(Color(hex: subject.colorHex).opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: subject.colorHex).opacity(0.3), lineWidth: 2)
        )
    }
}

struct AddSubjectPromptCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.primaryGradient)
            
            Text("添加科目")
                .font(.headline)
        }
        .frame(width: 180, height: 140)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [8]))
        )
    }
}

