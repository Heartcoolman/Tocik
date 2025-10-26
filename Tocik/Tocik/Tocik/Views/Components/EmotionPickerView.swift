//
//  EmotionPickerView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 情绪选择器
//

import SwiftUI

struct EmotionPickerView: View {
    @Binding var selectedMood: HabitRecord.Mood?
    
    let moods: [HabitRecord.Mood] = [.veryBad, .bad, .neutral, .good, .veryGood]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("今天的心情")
                .font(Theme.headlineFont)
            
            HStack(spacing: Theme.spacing.large) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedMood == mood {
                                selectedMood = nil
                            } else {
                                selectedMood = mood
                                HapticManager.shared.light()
                            }
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                            
                            Text(moodLabel(mood))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(
                            selectedMood == mood ?
                            Color.blue.opacity(0.1) :
                            Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func moodLabel(_ mood: HabitRecord.Mood) -> String {
        switch mood {
        case .veryBad: return "很差"
        case .bad: return "不好"
        case .neutral: return "一般"
        case .good: return "不错"
        case .veryGood: return "很好"
        }
    }
}

