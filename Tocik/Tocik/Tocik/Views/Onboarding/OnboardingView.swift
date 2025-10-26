//
//  OnboardingView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 新手引导
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "欢迎使用 Tocik",
            description: "强大的学习生产力工具\n30+功能助力您的成长",
            imageName: "sparkles",
            gradient: Theme.primaryGradient
        ),
        OnboardingPage(
            title: "番茄钟专注法",
            description: "使用番茄钟技术提高专注力\n智能分析学习模式",
            imageName: "timer",
            gradient: Theme.pomodoroGradient
        ),
        OnboardingPage(
            title: "智能学习系统",
            description: "闪卡间隔重复、错题管理\n笔记版本历史、模板系统",
            imageName: "brain.head.profile",
            gradient: Theme.flashcardGradient
        ),
        OnboardingPage(
            title: "成就与成长",
            description: "17种成就自动解锁\n等级系统见证您的进步",
            imageName: "crown.fill",
            gradient: Theme.goalGradient
        ),
        OnboardingPage(
            title: "开始您的旅程",
            description: "现在开始，创造更好的自己\n让学习变得高效而有趣",
            imageName: "figure.walk",
            gradient: Theme.habitGradient
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景渐变
            pages[currentPage].gradient
                .ignoresSafeArea()
                .opacity(0.1)
            
            VStack(spacing: 0) {
                // 跳过按钮
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("跳过") {
                            completeOnboarding()
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
                
                // 页面内容
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // 指示器和按钮
                VStack(spacing: Theme.spacing.large) {
                    // 页面指示器
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[currentPage].gradient : LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom)
                    
                    // 按钮
                    if currentPage == pages.count - 1 {
                        Button(action: completeOnboarding) {
                            Text("开始使用")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(pages[currentPage].gradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Button(action: { withAnimation { currentPage += 1 } }) {
                            HStack {
                                Text("下一步")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(pages[currentPage].gradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            dismiss()
        }
        HapticManager.shared.success()
    }
}

// MARK: - 模型

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let gradient: LinearGradient
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: Theme.spacing.xlarge) {
            Spacer()
            
            // 图标
            ZStack {
                Circle()
                    .fill(page.gradient)
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .opacity(0.6)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 80))
                    .foregroundStyle(page.gradient)
            }
            
            // 文字
            VStack(spacing: Theme.spacing.medium) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - 功能提示

struct FeatureTipView: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            // 图标
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            // 标题
            Text(title)
                .font(.headline)
            
            // 描述
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 按钮
            Button(action: { withAnimation { isShowing = false } }) {
                Text("知道了")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(gradient)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .padding(40)
    }
}

// MARK: - 快速入门指南

struct QuickStartGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    let guides: [(icon: String, title: String, description: String, gradient: LinearGradient)] = [
        ("timer", "开始第一个番茄钟", "点击番茄钟，选择模式后开始专注学习", Theme.pomodoroGradient),
        ("checklist", "创建待办任务", "添加今日要完成的任务，设置优先级", Theme.todoGradient),
        ("star.fill", "建立好习惯", "创建习惯追踪，每天坚持打卡", Theme.habitGradient),
        ("doc.text", "使用笔记模板", "选择合适的模板，快速开始记录", Theme.primaryGradient),
        ("target", "设定学习目标", "使用OKR方法设定清晰的目标", Theme.goalGradient),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.large) {
                    // 标题
                    VStack(spacing: Theme.spacing.small) {
                        Text("快速入门")
                            .font(.largeTitle.bold())
                        
                        Text("5分钟了解核心功能")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // 指南列表
                    ForEach(Array(guides.enumerated()), id: \.offset) { index, guide in
                        GuideStepView(
                            step: index + 1,
                            icon: guide.icon,
                            title: guide.title,
                            description: guide.description,
                            gradient: guide.gradient
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GuideStepView: View {
    let step: Int
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            // 步骤数字
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 50, height: 50)
                
                Text("\(step)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(gradient)
                    Text(title)
                        .font(.headline)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

