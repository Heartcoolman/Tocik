//
//  AchievementView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 成就展示
//

import SwiftUI
import SwiftData

struct AchievementView: View {
    @Query private var achievements: [Achievement]
    @Query private var userLevels: [UserLevel]
    @Environment(\.modelContext) private var context
    
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.xlarge) {
                    // 用户等级卡片
                    if let userLevel = userLevels.first {
                        UserLevelCard(userLevel: userLevel)
                    }
                    
                    // 成就统计
                    AchievementStatsCard(
                        total: achievements.count,
                        unlocked: unlockedCount,
                        totalPoints: totalPoints
                    )
                    
                    // 分类筛选
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.spacing.small) {
                            CategoryChip(
                                title: "全部",
                                count: achievements.count,
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                                let count = achievements.filter { $0.category == category }.count
                                CategoryChip(
                                    title: category.rawValue,
                                    count: count,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 成就列表
                    LazyVStack(spacing: Theme.spacing.medium) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCardView(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("成就")
            .onAppear {
                initializeAchievementsIfNeeded()
            }
        }
    }
    
    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalPoints: Int {
        achievements.filter { $0.isUnlocked }.reduce(0) { $0 + $1.rewardPoints }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    private func initializeAchievementsIfNeeded() {
        if achievements.isEmpty {
            let defaults = Achievement.createDefaultAchievements()
            for achievement in defaults {
                context.insert(achievement)
            }
        }
        
        if userLevels.isEmpty {
            let userLevel = UserLevel()
            context.insert(userLevel)
        }
    }
}

// 用户等级卡片
struct UserLevelCard: View {
    let userLevel: UserLevel
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            // 等级信息
            VStack(spacing: Theme.spacing.small) {
                Text("LV \(userLevel.currentLevel)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryGradient)
                
                Text(userLevel.levelTitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // 进度条
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(userLevel.currentLevelPoints) / \(userLevel.nextLevelPoints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(userLevel.levelProgress * 100))%")
                        .font(.caption.bold())
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                        
                        // 进度
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.primaryGradient)
                            .frame(width: geometry.size.width * userLevel.levelProgress)
                    }
                }
                .frame(height: 20)
            }
            
            // 总积分
            Text("总积分：\(userLevel.totalPoints)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.heroCornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        .padding(.horizontal)
    }
}

// 成就统计卡片
struct AchievementStatsCard: View {
    let total: Int
    let unlocked: Int
    let totalPoints: Int
    
    var body: some View {
        HStack(spacing: Theme.spacing.large) {
            AchievementStatItem(title: "总计", value: "\(total)", icon: "star")
            
            Divider()
            
            AchievementStatItem(title: "已解锁", value: "\(unlocked)", icon: "star.fill")
            
            Divider()
            
            AchievementStatItem(title: "积分", value: "\(totalPoints)", icon: "crown.fill")
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .padding(.horizontal)
    }
}

struct AchievementStatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.primaryGradient)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// 分类筛选芯片
struct CategoryChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())
                
                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                AnyShapeStyle(Theme.primaryGradient) :
                AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// 成就卡片
struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [Color(hex: achievement.category.colorHex), Color(hex: achievement.category.colorHex).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 60, height: 60)
                
                Text(achievement.icon)
                    .font(.system(size: 30))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 进度或解锁时间
                if achievement.isUnlocked {
                    if let date = achievement.unlockedDate {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("解锁于 \(formatDate(date))")
                        }
                        .font(.caption)
                    }
                } else {
                    ProgressView(value: achievement.progressPercentage) {
                        Text("\(achievement.progress) / \(achievement.requirement)")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            // 积分
            VStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("+\(achievement.rewardPoints)")
                    .font(.caption.bold())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

