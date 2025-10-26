//
//  ModernToolSection.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct ModernToolSection: View {
    let title: String
    let tools: [ToolItem]
    let icon: String
    let gradient: LinearGradient
    let onToolTap: ((ToolItem) -> Void)?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isAppeared = false
    
    init(title: String, tools: [ToolItem], icon: String, gradient: LinearGradient, onToolTap: ((ToolItem) -> Void)? = nil) {
        self.title = title
        self.tools = tools
        self.icon = icon
        self.gradient = gradient
        self.onToolTap = onToolTap
    }
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: Theme.spacing.medium), count: count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.large) {
            // 分组标题
            HStack(spacing: Theme.spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(gradient)
                
                Text(title)
                    .font(Theme.titleFont)
                    .foregroundStyle(gradient)
            }
            .padding(.horizontal, Theme.spacing.large)
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared ? 0 : -20)
            
            // 工具网格
            LazyVGrid(columns: columns, spacing: Theme.spacing.medium) {
                ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                    Group {
                        if let onTap = onToolTap {
                            // 使用回调方式
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                onTap(tool)
                            }) {
                                ModernToolCard(tool: tool)
                            }
                            .buttonStyle(CardButtonStyle())
                        } else {
                            // 使用NavigationLink方式
                            NavigationLink(value: tool) {
                                ModernToolCard(tool: tool)
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }
                    .opacity(isAppeared ? 1 : 0)
                    .offset(y: isAppeared ? 0 : 50)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.08),
                        value: isAppeared
                    )
                }
            }
            .padding(.horizontal, Theme.spacing.medium)
        }
        .onAppear {
            isAppeared = true
        }
        .onChange(of: tools.count) { _, _ in
            // 当工具列表变化时，重新触发动画
            isAppeared = false
            withAnimation {
                isAppeared = true
            }
        }
    }
}

struct ModernToolCard: View {
    let tool: ToolItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            // 图标（带渐变背景）
            ZStack {
                // 渐变背景圆
                LinearGradient(
                    colors: [tool.color.opacity(0.3), tool.color.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                
                // 图标
                if !tool.icon.isEmpty {
                    Image(systemName: tool.icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tool.color, tool.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            // 名称
            Text(tool.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(.systemGray6)
                } else {
                    Color.white
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [tool.color.opacity(0.3), tool.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.08),
            radius: 15,
            x: 0,
            y: 8
        )
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.04),
            radius: 30,
            x: 0,
            y: 15
        )
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.bounceAnimation, value: configuration.isPressed)
    }
}

#Preview {
    ModernToolSection(
        title: "核心工具",
        tools: [
            ToolItem(id: "test", name: "番茄时钟", icon: "timer", color: .red)
        ],
        icon: "star.fill",
        gradient: Theme.primaryGradient
    )
    .padding()
}

