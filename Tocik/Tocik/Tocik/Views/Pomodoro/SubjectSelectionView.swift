//
//  SubjectSelectionView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/24.
//  v5.0 - 科目选择视图
//

import SwiftUI
import SwiftData

struct SubjectSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSubject: Subject?
    let subjects: [Subject]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    Button(action: {
                        selectedSubject = subject
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: subject.icon)
                                .font(.title2)
                                .foregroundColor(Color(hex: subject.colorHex))
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subject.name)
                                    .font(Theme.bodyFont)
                                    .foregroundColor(.primary)
                                
                                Text(String(format: "已学习 %.1fh", subject.totalStudyHours))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedSubject?.id == subject.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择学习科目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SubjectSelectionView(
        selectedSubject: .constant(nil),
        subjects: []
    )
}

