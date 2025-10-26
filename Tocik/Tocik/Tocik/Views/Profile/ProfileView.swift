//
//  ProfileView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 个人中心（全新设计）
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var userLevels: [UserLevel]
    @Query private var achievements: [Achievement]
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    @Query private var notes: [Note]
    @Query private var userProfiles: [UserProfile]  // v5.0: 添加用户画像查询
    
    @StateObject private var themeStore = ThemeStore.shared
    @State private var showThemeSelection = false
    @State private var showSettings = false
    @State private var showPersonalGrowth = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.xlarge) {
                    // 顶部用户信息卡
                    ProfileHeaderCard(userLevel: userLevels.first)
                    
                    // 等级进度大卡片
                    if let level = userLevels.first {
                        LevelProgressCard(userLevel: level)
                    }
                    
                    // 4个关键数据
                    KeyMetricsSection(
                        totalPomodoros: totalPomodoros,
                        completedTodos: completedTodos,
                        maxStreak: maxStreak,
                        unlockedAchievements: unlockedAchievements
                    )
                    
                    // 成就墙（最近解锁的5个）
                    RecentAchievementsWall(
                        achievements: recentUnlockedAchievements
                    )
                    
                    // 学习数据概览
                    StudyDataOverview(
                        notes: notes.count,
                        totalWords: totalWords,
                        studyDays: studyDays
                    )
                    
                    // AI使用统计（v5.0新增）
                    if let profile = userProfiles.first {
                        AIUsageSection(userProfile: profile)
                    }
                    
                    // 设置和功能入口
                    SettingsSection(
                        onTheme: { showThemeSelection = true },
                        onPersonalization: { showSettings = true },
                        onGrowthReport: { showPersonalGrowth = true }
                    )
                }
                .padding()
            }
            .background(
                ZStack {
                    Color(.systemGroupedBackground)
                    
                    // 顶部装饰渐变
                    themeStore.currentTheme.primaryGradient
                        .opacity(0.1)
                        .blur(radius: 100)
                        .offset(y: -300)
                        .ignoresSafeArea()
                }
            )
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showThemeSelection) {
                ThemeSelectionView()
            }
            .sheet(isPresented: $showSettings) {
                CustomizationView()
            }
            .sheet(isPresented: $showPersonalGrowth) {
                NavigationStack {
                    PersonalGrowthView()
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var totalPomodoros: Int {
        pomodoroSessions.filter { $0.isCompleted }.count
    }
    
    private var completedTodos: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    private var maxStreak: Int {
        habits.map { $0.getCurrentStreak() }.max() ?? 0
    }
    
    private var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    private var recentUnlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? Date.distantPast) > ($1.unlockedDate ?? Date.distantPast) }
            .prefix(5)
            .map { $0 }
    }
    
    private var totalWords: Int {
        notes.reduce(0) { $0 + $1.wordCount }
    }
    
    private var studyDays: Int {
        let calendar = Calendar.current
        let allDates = pomodoroSessions.compactMap {
            calendar.startOfDay(for: $0.startTime)
        }
        return Set(allDates).count
    }
}

// MARK: - 子视图

struct ProfileHeaderCard: View {
    let userLevel: UserLevel?
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // 大头像和等级环
            ZStack {
                // 外圈装饰
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 140, height: 140)
                
                // 进度环
                if let level = userLevel {
                    Circle()
                        .trim(from: 0, to: level.levelProgress)
                        .stroke(Theme.primaryGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1), value: level.levelProgress)
                }
                
                // 头像
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
            
            // 用户名和等级
            VStack(spacing: 4) {
                TextField("用户名", text: .constant("Tocik用户"))
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .disabled(true)
                
                if let level = userLevel {
                    HStack(spacing: 12) {
                        Text("Lv \(level.currentLevel)")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.primaryGradient)
                        
                        Text("|")
                            .foregroundColor(.secondary)
                        
                        Text(level.levelTitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.heroCornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}

struct LevelProgressCard: View {
    let userLevel: UserLevel
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            // 进度信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("升级进度")
                        .font(.headline)
                    Text("\(userLevel.currentLevelPoints) / \(userLevel.nextLevelPoints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(userLevel.levelProgress * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.primaryGradient)
            }
            
            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.primaryGradient)
                        .frame(width: geo.size.width * userLevel.levelProgress)
                        .animation(.spring(response: 1), value: userLevel.levelProgress)
                }
            }
            .frame(height: 20)
            
            // 总积分
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("总积分: \(userLevel.totalPoints)")
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct KeyMetricsSection: View {
    let totalPomodoros: Int
    let completedTodos: Int
    let maxStreak: Int
    let unlockedAchievements: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(
                value: "\(totalPomodoros)",
                title: "番茄钟",
                icon: "timer",
                gradient: Theme.pomodoroGradient
            )
            
            MetricCard(
                value: "\(completedTodos)",
                title: "已完成",
                icon: "checkmark.circle",
                gradient: Theme.todoGradient
            )
            
            MetricCard(
                value: "\(maxStreak)天",
                title: "最长连续",
                icon: "flame.fill",
                gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            
            MetricCard(
                value: "\(unlockedAchievements)",
                title: "成就",
                icon: "trophy.fill",
                gradient: LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }
}

struct MetricCard: View {
    let value: String
    let title: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(gradient)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct RecentAchievementsWall: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("最近解锁")
                .font(.title3.bold())
            
            if achievements.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("继续努力解锁成就")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: achievement.category.colorHex), Color(hex: achievement.category.colorHex).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(achievement.icon)
                    .font(.title)
            }
            
            Text(achievement.name)
                .font(.caption2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
        }
    }
}

struct StudyDataOverview: View {
    let notes: Int
    let totalWords: Int
    let studyDays: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("学习数据")
                .font(.title3.bold())
            
            VStack(spacing: 12) {
                DataRow(icon: "doc.text", title: "笔记总数", value: "\(notes)篇", color: .blue)
                DataRow(icon: "textformat.size", title: "总字数", value: formatWords(totalWords), color: .purple)
                DataRow(icon: "calendar", title: "学习天数", value: "\(studyDays)天", color: .green)
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func formatWords(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000.0)
        }
        return "\(count)"
    }
}

struct DataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
        }
        .padding(.vertical, 4)
    }
}

struct SettingsSection: View {
    let onTheme: () -> Void
    let onPersonalization: () -> Void
    let onGrowthReport: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            SettingsButton(
                icon: "paintpalette.fill",
                title: "主题",
                description: "7套精美主题",
                color: .pink,
                action: onTheme
            )
            
            SettingsButton(
                icon: "slider.horizontal.3",
                title: "个性化",
                description: "定制您的体验",
                color: .blue,
                action: onPersonalization
            )
            
            SettingsButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "成长报告",
                description: "查看进步轨迹",
                color: .green,
                action: onGrowthReport
            )
            
            NavigationLink {
                DataManagementView()
            } label: {
                SettingsButtonLabel(
                    icon: "gearshape.fill",
                    title: "数据管理",
                    description: "备份和清理",
                    color: .gray
                )
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SettingsButtonLabel(icon: icon, title: title, description: description, color: color)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsButtonLabel: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - v5.0 AI使用统计

struct AIUsageSection: View {
    let userProfile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Image(systemName: "brain")
                    .foregroundStyle(Theme.primaryGradient)
                Text("AI使用统计")
                    .font(.title3.bold())
            }
            
            VStack(spacing: 12) {
                // Token消耗
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token消耗")
                            .font(.subheadline)
                        Text("本月")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatTokens(userProfile.lastMonthTokensUsed))
                            .font(.headline.bold())
                            .foregroundStyle(Theme.primaryGradient)
                        Text("总计: \(formatTokens(userProfile.totalTokensUsed))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 调用次数
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    AICallCard(
                        icon: "chart.bar.fill",
                        label: "分析次数",
                        value: "\(userProfile.totalAIAnalysisCalls)",
                        color: .blue
                    )
                    
                    AICallCard(
                        icon: "lightbulb.fill",
                        label: "推荐次数",
                        value: "\(userProfile.totalAIRecommendationCalls)",
                        color: .orange
                    )
                }
                
                // 建议接受率
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("建议接受率")
                            .font(.subheadline)
                        Text("AI建议的采纳率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%%", userProfile.acceptanceRate * 100))
                        .font(.title2.bold())
                        .foregroundColor(acceptanceRateColor)
                }
                .padding()
                .background(acceptanceRateColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func formatTokens(_ tokens: Int) -> String {
        if tokens >= 1000000 {
            return String(format: "%.1fM", Double(tokens) / 1000000.0)
        } else if tokens >= 1000 {
            return String(format: "%.1fK", Double(tokens) / 1000.0)
        }
        return "\(tokens)"
    }
    
    private var acceptanceRateColor: Color {
        if userProfile.acceptanceRate >= 0.7 { return .green }
        if userProfile.acceptanceRate >= 0.4 { return .orange }
        return .red
    }
}

struct AICallCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
