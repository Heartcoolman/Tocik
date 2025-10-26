//
//  ThemeStore.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 主题商店
//

import SwiftUI
import Combine

class ThemeStore: ObservableObject {
    @Published var currentTheme: AppTheme = .default
    @AppStorage("selectedThemeId") private var selectedThemeId: String = "default"
    
    static let shared = ThemeStore()
    
    private init() {
        if let theme = availableThemes.first(where: { $0.id == selectedThemeId }) {
            currentTheme = theme
        }
    }
    
    // 可用主题
    let availableThemes: [AppTheme] = [
        .default,
        .ocean,
        .sunset,
        .forest,
        .lavender,
        .monochrome,
        .candy
    ]
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        selectedThemeId = theme.id
    }
}

// 应用主题
struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let primaryGradient: LinearGradient
    let secondaryGradient: LinearGradient
    let accentColor: Color
    let backgroundColor: Color
    let cardColor: Color
    
    // 手动实现 Equatable（仅比较 id）
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        lhs.id == rhs.id
    }
    
    // 默认主题
    static let `default` = AppTheme(
        id: "default",
        name: "默认",
        description: "经典蓝紫渐变",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#F093FB"), Color(hex: "#F5576C")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#667EEA"),
        backgroundColor: Color(hex: "#F5F7FA"),
        cardColor: .white
    )
    
    // 海洋主题
    static let ocean = AppTheme(
        id: "ocean",
        name: "海洋",
        description: "清新蓝绿色调",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#2E3192"), Color(hex: "#1BFFFF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#00D2FF"), Color(hex: "#3A7BD5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#00D2FF"),
        backgroundColor: Color(hex: "#E8F4F8"),
        cardColor: .white
    )
    
    // 日落主题
    static let sunset = AppTheme(
        id: "sunset",
        name: "日落",
        description: "温暖橙红色调",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#FF512F"), Color(hex: "#F09819")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#FDC830"), Color(hex: "#F37335")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#FF512F"),
        backgroundColor: Color(hex: "#FFF5EB"),
        cardColor: .white
    )
    
    // 森林主题
    static let forest = AppTheme(
        id: "forest",
        name: "森林",
        description: "自然绿色调",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#11998E"), Color(hex: "#38EF7D")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#56AB2F"), Color(hex: "#A8E063")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#11998E"),
        backgroundColor: Color(hex: "#F0F8F4"),
        cardColor: .white
    )
    
    // 薰衣草主题
    static let lavender = AppTheme(
        id: "lavender",
        name: "薰衣草",
        description: "优雅紫色调",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#B993D6"), Color(hex: "#8CA6DB")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#A18CD1"), Color(hex: "#FBC2EB")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#B993D6"),
        backgroundColor: Color(hex: "#F7F3F9"),
        cardColor: .white
    )
    
    // 黑白主题
    static let monochrome = AppTheme(
        id: "monochrome",
        name: "黑白",
        description: "简约单色",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#000000"), Color(hex: "#434343")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#636363"), Color(hex: "#A3A3A3")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#000000"),
        backgroundColor: Color(hex: "#F5F5F5"),
        cardColor: .white
    )
    
    // 糖果主题
    static let candy = AppTheme(
        id: "candy",
        name: "糖果",
        description: "活力彩色",
        primaryGradient: LinearGradient(
            colors: [Color(hex: "#FF6FD8"), Color(hex: "#3813C2")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        secondaryGradient: LinearGradient(
            colors: [Color(hex: "#FE5196"), Color(hex: "#F77062")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        accentColor: Color(hex: "#FF6FD8"),
        backgroundColor: Color(hex: "#FFF0F9"),
        cardColor: .white
    )
}

// 主题预览卡片
struct ThemePreviewCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // 渐变预览
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryGradient)
                    .frame(height: 80)
                
                // 主题信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.headline)
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}

