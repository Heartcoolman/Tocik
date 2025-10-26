//
//  Theme.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v3.1 - 视觉升级版

import SwiftUI

struct Theme {
    // MARK: - 现代化渐变色系统
    
    // 主题渐变（蓝紫到青绿）
    static let primaryMeshGradient = LinearGradient(
        colors: [
            Color(hex: "#667EEA"),
            Color(hex: "#764BA2"),
            Color(hex: "#48C6EF")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [Color(hex: "#F093FB"), Color(hex: "#F5576C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 功能模块渐变色
    
    static let pomodoroGradient = LinearGradient(
        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E53"), Color(hex: "#FFAB7B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let todoGradient = LinearGradient(
        colors: [Color(hex: "#4ECDC4"), Color(hex: "#44A08D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let courseGradient = LinearGradient(
        colors: [Color(hex: "#FFD93D"), Color(hex: "#F6D365")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let calendarGradient = LinearGradient(
        colors: [Color(hex: "#95E1D3"), Color(hex: "#38EF7D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let habitGradient = LinearGradient(
        colors: [Color(hex: "#A78BFA"), Color(hex: "#8B5CF6"), Color(hex: "#7C3AED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let weatherGradient = LinearGradient(
        colors: [Color(hex: "#60A5FA"), Color(hex: "#3B82F6"), Color(hex: "#2563EB")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let statsGradient = LinearGradient(
        colors: [Color(hex: "#34D399"), Color(hex: "#10B981")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goalGradient = LinearGradient(
        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let flashcardGradient = LinearGradient(
        colors: [Color(hex: "#8B5CF6"), Color(hex: "#6366F1")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 学习场景渐变（v4.1新增）
    
    static let classGradient = LinearGradient(
        colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let homeworkGradient = LinearGradient(
        colors: [Color(hex: "#FFD93D"), Color(hex: "#FF9A3D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let reviewGradient = LinearGradient(
        colors: [Color(hex: "#A78BFA"), Color(hex: "#8B5CF6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let examGradient = LinearGradient(
        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E53")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 学科颜色系统（v4.1新增）
    
    static let subjectColors: [String: String] = [
        "数学": "#FF6B9D",
        "语文": "#4ECDC4",
        "英语": "#FFD93D",
        "物理": "#667EEA",
        "化学": "#95E1D3",
        "生物": "#34D399",
        "历史": "#A78BFA",
        "地理": "#60A5FA",
        "政治": "#F472B6",
        "其他": "#94A3B8"
    ]
    
    // MARK: - 单色主题（兼容）
    static let primaryColor = Color(hex: "#667EEA")
    static let secondaryColor = Color(hex: "#48C6EF")
    static let accentColor = Color(hex: "#F5576C")
    
    static let pomodoroColor = Color(hex: "#FF6B6B")
    static let todoColor = Color(hex: "#4ECDC4")
    static let courseColor = Color(hex: "#FFD93D")
    static let calendarColor = Color(hex: "#95E1D3")
    static let habitColor = Color(hex: "#A78BFA")
    static let weatherColor = Color(hex: "#60A5FA")
    static let countdownColor = Color(hex: "#F472B6")
    static let statsColor = Color(hex: "#34D399")
    static let readerColor = Color(hex: "#FB923C")
    static let noteColor = Color(hex: "#A78BFA")
    static let calculatorColor = Color(hex: "#818CF8")
    static let converterColor = Color(hex: "#2DD4BF")
    static let focusColor = Color(hex: "#C084FC")
    
    // MARK: - 文字系统（优化）
    static let heroFont: Font = .system(size: 56, weight: .black, design: .rounded)
    static let titleFont: Font = .system(size: 32, weight: .bold, design: .rounded)
    static let headlineFont: Font = .system(size: 22, weight: .semibold, design: .rounded)
    static let bodyFont: Font = .system(size: 17, weight: .regular)
    static let captionFont: Font = .system(size: 15, weight: .regular)
    static let smallFont: Font = .system(size: 13, weight: .regular)
    
    // MARK: - 圆角系统
    static let heroCornerRadius: CGFloat = 32
    static let largeCornerRadius: CGFloat = 24
    static let cornerRadius: CGFloat = 20
    static let mediumCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let miniCornerRadius: CGFloat = 8
    
    // MARK: - 间距系统（8px基准）
    static let spacing = SpacingSystem()
    
    struct SpacingSystem {
        let mini: CGFloat = 4
        let small: CGFloat = 8
        let medium: CGFloat = 16
        let large: CGFloat = 24
        let xlarge: CGFloat = 32
        let xxlarge: CGFloat = 48
    }
    
    // MARK: - 动画预设
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)
    static let bounceAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 15)
}

// MARK: - View扩展（新增视觉效果）
extension View {
    // 玻璃态效果
    func glassEffect(cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
    }
    
    // 渐变卡片效果
    func gradientCard(gradient: LinearGradient, cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        self
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.05), radius: 40, x: 0, y: 20)
    }
    
    // 浮动卡片效果（多层阴影）
    func floatingCard(colorScheme: ColorScheme = .light, cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        self
            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.04), radius: 30, x: 0, y: 15)
    }
    
    // 发光效果
    func glowEffect(color: Color, intensity: CGFloat = 0.6) -> some View {
        self
            .shadow(color: color.opacity(intensity), radius: 20, x: 0, y: 0)
            .shadow(color: color.opacity(intensity * 0.5), radius: 40, x: 0, y: 0)
    }
    
    // 渐变边框
    func gradientBorder(gradient: LinearGradient, lineWidth: CGFloat = 2, cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(gradient, lineWidth: lineWidth)
            )
    }
    
    // 按压效果
    func pressEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(Theme.bounceAnimation, value: UUID())
    }
    
    // 悬浮动画
    func hoverEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(Theme.springAnimation, value: isPressed)
    }
}

// Color扩展支持十六进制（保留）
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

// MARK: - 渐变色扩展
extension LinearGradient {
    // 柔和渐变
    static let softPink = LinearGradient(
        colors: [Color(hex: "#FEC6D1"), Color(hex: "#FDA5B8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let softBlue = LinearGradient(
        colors: [Color(hex: "#A8EDEA"), Color(hex: "#6DD5ED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let softPurple = LinearGradient(
        colors: [Color(hex: "#D299C2"), Color(hex: "#9055A2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunset = LinearGradient(
        colors: [Color(hex: "#FF9A9E"), Color(hex: "#FAD0C4"), Color(hex: "#FFD1FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
