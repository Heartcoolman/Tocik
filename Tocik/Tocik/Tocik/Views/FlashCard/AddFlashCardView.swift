//
//  AddFlashCardView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddFlashCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: FlashDeck
    
    @State private var question = ""
    @State private var answer = ""
    @State private var difficulty: FlashCard.Difficulty = .medium
    
    var body: some View {
        NavigationStack {
            Form {
                Section("问题") {
                    TextEditor(text: $question)
                        .frame(minHeight: 100)
                }
                
                Section("答案") {
                    TextEditor(text: $answer)
                        .frame(minHeight: 100)
                }
                
                Section("难度") {
                    Picker("难度", selection: $difficulty) {
                        ForEach(FlashCard.Difficulty.allCases, id: \.self) { diff in
                            HStack {
                                Circle()
                                    .fill(Color(hex: diff.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(diff.displayName)
                            }
                            .tag(diff)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("添加卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveCard()
                    }
                    .disabled(question.isBlank || answer.isBlank)
                }
            }
        }
    }
    
    private func saveCard() {
        let card = FlashCard(question: question, answer: answer, difficulty: difficulty)
        modelContext.insert(card)
        deck.cards.append(card)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FlashDeck.self, configurations: config)
    
    let deck = FlashDeck(name: "测试卡片组")
    
    return AddFlashCardView(deck: deck)
        .modelContainer(container)
}

