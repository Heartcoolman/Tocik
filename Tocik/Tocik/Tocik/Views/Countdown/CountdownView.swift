//
//  CountdownView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct CountdownView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Countdown.targetDate) private var countdowns: [Countdown]
    
    @State private var showingAddCountdown = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if countdowns.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("添加重要日期倒计时")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(countdowns) { countdown in
                                CountdownCard(countdown: countdown)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            modelContext.delete(countdown)
                                            try? modelContext.save()
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("倒数日")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCountdown = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.countdownColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddCountdown) {
                AddCountdownView()
            }
        }
    }
}

struct CountdownCard: View {
    let countdown: Countdown
    
    var daysRemaining: Int {
        countdown.daysRemaining()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标
            Image(systemName: countdown.icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color(hex: countdown.colorHex))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(countdown.title)
                    .font(Theme.headlineFont)
                
                Text(countdown.targetDate.formatted("yyyy年MM月dd日"))
                    .font(Theme.captionFont)
                    .foregroundColor(.secondary)
                
                if !countdown.eventDescription.isEmpty {
                    Text(countdown.eventDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(daysRemaining >= 0 ? "\(daysRemaining)" : "已过")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: countdown.colorHex))
                
                if daysRemaining >= 0 {
                    Text("天")
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadius)
        .shadow(radius: 2)
        .opacity(daysRemaining < 0 ? 0.5 : 1.0)
    }
}

#Preview {
    CountdownView()
        .modelContainer(for: Countdown.self, inMemory: true)
}

