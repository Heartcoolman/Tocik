//
//  FlashCardView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct FlashCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [FlashDeck]
    
    @State private var showingAddDeck = false
    @State private var selectedDeck: FlashDeck?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if decks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("创建您的第一个卡片组")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(decks) { deck in
                                DeckCard(deck: deck)
                                    .onTapGesture {
                                        selectedDeck = deck
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("学习闪卡")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDeck = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                AddFlashDeckView()
            }
            .sheet(item: $selectedDeck) { deck in
                FlashDeckDetailView(deck: deck)
            }
        }
    }
}

struct DeckCard: View {
    let deck: FlashDeck
    
    var needsReview: Int {
        deck.cardsNeedReview()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 卡片堆图标
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: deck.colorHex).opacity(0.3))
                    .frame(width: 60, height: 80)
                    .offset(x: -4, y: -4)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: deck.colorHex).opacity(0.6))
                    .frame(width: 60, height: 80)
                    .offset(x: -2, y: -2)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: deck.colorHex))
                    .frame(width: 60, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(deck.name)
                    .font(Theme.headlineFont)
                
                if !deck.deckDescription.isEmpty {
                    Text(deck.deckDescription)
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label("\(deck.cards.count) 张卡片", systemImage: "rectangle.stack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if needsReview > 0 {
                        Label("\(needsReview) 待复习", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            if needsReview > 0 {
                VStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(needsReview)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
    }
}

#Preview {
    FlashCardView()
        .modelContainer(for: FlashDeck.self, inMemory: true)
}

