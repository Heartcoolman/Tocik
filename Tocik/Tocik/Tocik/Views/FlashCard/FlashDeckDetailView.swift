//
//  FlashDeckDetailView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct FlashDeckDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: FlashDeck
    
    @State private var showingAddCard = false
    @State private var showingStudy = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 统计卡片
                HStack(spacing: 20) {
                    StatBox(title: "总卡片", value: "\(deck.cards.count)", color: Color(hex: deck.colorHex))
                    StatBox(title: "待复习", value: "\(deck.cardsNeedReview())", color: .orange)
                    StatBox(title: "已掌握", value: "\(masteredCards)", color: .green)
                }
                .padding()
                
                // 开始学习按钮
                if deck.cardsNeedReview() > 0 {
                    Button(action: { showingStudy = true }) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("开始复习 (\(deck.cardsNeedReview())张)")
                        }
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: deck.colorHex))
                        .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                // 卡片列表
                List {
                    ForEach(deck.cards) { card in
                        FlashCardRow(card: card)
                    }
                    .onDelete(perform: deleteCards)
                }
            }
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddFlashCardView(deck: deck)
            }
            .fullScreenCover(isPresented: $showingStudy) {
                FlashCardStudyView(deck: deck)
            }
        }
    }
    
    private var masteredCards: Int {
        deck.cards.filter { $0.correctCount >= 3 && $0.interval >= 7 }.count
    }
    
    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            let card = deck.cards[index]
            modelContext.delete(card)
            deck.cards.remove(at: index)
        }
        try? modelContext.save()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.smallCornerRadius)
    }
}

struct FlashCardRow: View {
    let card: FlashCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.question)
                .font(Theme.bodyFont)
                .lineLimit(2)
            
            HStack {
                Label(card.difficulty.displayName, systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: card.difficulty.colorHex))
                
                Spacer()
                
                if card.nextReviewDate <= Date() {
                    Text("需要复习")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("下次: \(card.nextReviewDate.formatted("MM/dd"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FlashDeck.self, configurations: config)
    
    let deck = FlashDeck(name: "英语单词")
    
    return FlashDeckDetailView(deck: deck)
        .modelContainer(container)
}

