//
//  CourseNotesView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct CourseNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [Note]
    
    let courseId: UUID
    let courseName: String
    
    var courseNotes: [Note] {
        allNotes.filter { $0.relatedCourseId == courseId }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if courseNotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "note.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("暂无\(courseName)的笔记")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(courseNotes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.title)
                                .font(Theme.bodyFont)
                            
                            Text(note.content)
                                .font(Theme.captionFont)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            Text(note.createdDate.formatted("yyyy/MM/dd"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("\(courseName) - 笔记")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CourseNotesView(courseId: UUID(), courseName: "高等数学")
        .modelContainer(for: Note.self, inMemory: true)
}

