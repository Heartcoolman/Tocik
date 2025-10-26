//
//  StudyModeSelector.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  学习模式切换器
//

import SwiftUI

struct StudyModeSelector: View {
    @Binding var mode: iPadCardWorkspace.StudyMode
    
    var body: some View {
        HStack(spacing: 12) {
            ModeButton(icon: "book.fill", title: "上课", mode: .classMode, currentMode: mode) {
                withAnimation { mode = .classMode }
            }
            
            ModeButton(icon: "pencil", title: "作业", mode: .homework, currentMode: mode) {
                withAnimation { mode = .homework }
            }
            
            ModeButton(icon: "arrow.triangle.2.circlepath", title: "复习", mode: .review, currentMode: mode) {
                withAnimation { mode = .review }
            }
            
            ModeButton(icon: "doc.text.fill", title: "备考", mode: .exam, currentMode: mode) {
                withAnimation { mode = .exam }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ModeButton: View {
    let icon: String
    let title: String
    let mode: iPadCardWorkspace.StudyMode
    let currentMode: iPadCardWorkspace.StudyMode
    let action: () -> Void
    
    var isActive: Bool {
        mode == currentMode
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isActive {
                    modeGradient
                } else {
                    Color.clear
                }
            }
            .foregroundColor(isActive ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
    
    private var modeGradient: LinearGradient {
        switch mode {
        case .classMode: return Theme.classGradient
        case .homework: return Theme.homeworkGradient
        case .review: return Theme.reviewGradient
        case .exam: return Theme.examGradient
        }
    }
}

