//
//  AchievementWidgetCard.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 成就小部件卡片
//

import SwiftUI
import SwiftData

struct AchievementWidgetCard: View {
    @Query private var achievements: [Achievement]
    @Query private var userLevels: [UserLevel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("成就")
                    .font(.headline)
                
                Spacer()
                
                if let level = userLevels.first {
                    Text("Lv \(level.currentLevel)")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.primaryGradient)
                }
            }
            
            // 解锁进度
            VStack(spacing: 8) {
                HStack {
                    Text("\(unlockedCount) / \(achievements.count)")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Text("\(Int(unlockRate * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.yellow)
                }
                
                // 进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * unlockRate)
                    }
                }
                .frame(height: 8)
                
                // 最近成就
                if let recentAchievement = mostRecentUnlocked {
                    HStack(spacing: 8) {
                        Text(recentAchievement.icon)
                        Text("最近解锁：\(recentAchievement.name)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    private var unlockRate: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
    }
    
    private var mostRecentUnlocked: Achievement? {
        achievements.filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
            .first
    }
}

