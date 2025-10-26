//
//  FlashCardStudyView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct FlashCardStudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let deck: FlashDeck
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var reviewedCount = 0
    @State private var correctCount = 0
    @State private var cardsToReview: [FlashCard] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color(hex: deck.colorHex).opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 进度
                    VStack(spacing: 8) {
                        Text("\(reviewedCount) / \(cardsToReview.count)")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: Double(reviewedCount), total: Double(cardsToReview.count))
                            .accentColor(Color(hex: deck.colorHex))
                    }
                    .padding(.horizontal)
                    
                    // 卡片
                    if currentIndex < cardsToReview.count {
                        FlipCard(
                            card: cardsToReview[currentIndex],
                            isFlipped: $isFlipped,
                            deckColor: Color(hex: deck.colorHex)
                        )
                        .frame(maxHeight: 400)
                    } else {
                        // 学习完成
                        CompletionView(
                            totalCards: cardsToReview.count,
                            correctCount: correctCount
                        )
                    }
                    
                    // 控制按钮
                    if currentIndex < cardsToReview.count && isFlipped {
                        HStack(spacing: 20) {
                            Button(action: { answerCard(remembered: false) }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 40))
                                    Text("不记得")
                                        .font(Theme.bodyFont)
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(Theme.cornerRadius)
                            }
                            
                            Button(action: { answerCard(remembered: true) }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 40))
                                    Text("记得")
                                        .font(Theme.bodyFont)
                                }
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(Theme.cornerRadius)
                            }
                        }
                        .padding(.horizontal)
                    } else if currentIndex < cardsToReview.count {
                        Button(action: { withAnimation { isFlipped = true } }) {
                            Text("显示答案")
                                .font(Theme.headlineFont)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: deck.colorHex))
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("退出") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                cardsToReview = deck.cards.filter { $0.nextReviewDate <= Date() }
            }
        }
    }
    
    private func answerCard(remembered: Bool) {
        let card = cardsToReview[currentIndex]
        
        // 使用SM-2算法计算下次复习时间
        let result = SM2Algorithm.simpleReview(card: card, remembered: remembered)
        card.interval = result.interval
        card.easeFactor = result.easeFactor
        card.nextReviewDate = result.nextReviewDate
        card.reviewCount += 1
        card.lastReviewDate = Date()
        
        if remembered {
            card.correctCount += 1
            correctCount += 1
        }
        
        try? modelContext.save()
        
        // 下一张卡片
        reviewedCount += 1
        currentIndex += 1
        isFlipped = false
    }
}

struct FlipCard: View {
    let card: FlashCard
    @Binding var isFlipped: Bool
    let deckColor: Color
    
    var body: some View {
        ZStack {
            // 背面（答案）
            CardSide(
                content: card.answer,
                title: "答案",
                color: deckColor,
                isAnswer: true
            )
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : 90), axis: (x: 0, y: 1, z: 0))
            
            // 正面（问题）
            CardSide(
                content: card.question,
                title: "问题",
                color: deckColor,
                isAnswer: false
            )
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? -90 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .padding()
    }
}

struct CardSide: View {
    let content: String
    let title: String
    let color: Color
    let isAnswer: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(.secondary)
            
            ScrollView {
                Text(content)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(isAnswer ? color.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(color, lineWidth: 2)
        )
        .shadow(radius: 8)
    }
}

struct CompletionView: View {
    let totalCards: Int
    let correctCount: Int
    
    var accuracy: Int {
        guard totalCards > 0 else { return 0 }
        return Int(Double(correctCount) / Double(totalCards) * 100)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("学习完成！")
                .font(.system(size: 32, weight: .bold))
            
            VStack(spacing: 12) {
                Text("复习了 \(totalCards) 张卡片")
                Text("正确率 \(accuracy)%")
            }
            .font(Theme.headlineFont)
            .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FlashDeck.self, configurations: config)
    
    let deck = FlashDeck(name: "测试")
    let card = FlashCard(question: "什么是Swift?", answer: "Apple的编程语言")
    deck.cards.append(card)
    
    return FlashCardStudyView(deck: deck)
        .modelContainer(container)
}

