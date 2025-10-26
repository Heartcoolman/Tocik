//
//  CustomizationView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 个性化定制
//

import SwiftUI

struct CustomizationView: View {
    @StateObject private var themeStore = ThemeStore.shared
    @AppStorage("fontSize") private var fontSize: FontSize = .medium
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("enableAnimations") private var enableAnimations = true
    
    enum FontSize: String, CaseIterable {
        case small = "小"
        case medium = "中"
        case large = "大"
        case extraLarge = "特大"
        
        var scale: CGFloat {
            switch self {
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.1
            case .extraLarge: return 1.2
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // 主题选择
                Section {
                    NavigationLink {
                        ThemeSelectionView()
                    } label: {
                        HStack {
                            Label("主题", systemImage: "paintpalette.fill")
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                ForEach([themeStore.currentTheme.accentColor], id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(themeStore.currentTheme.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("外观")
                }
                
                // 字体大小
                Section {
                    Picker("字体大小", selection: $fontSize) {
                        ForEach(FontSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("预览文字 (\(fontSize.rawValue))")
                        .font(.body)
                        .scaleEffect(fontSize.scale)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } header: {
                    Text("文字")
                }
                
                // 交互设置
                Section {
                    Toggle(isOn: $enableHaptics) {
                        Label("触觉反馈", systemImage: "hand.tap.fill")
                    }
                    .onChange(of: enableHaptics) { oldValue, newValue in
                        if newValue {
                            HapticManager.shared.success()
                        }
                    }
                    
                    Toggle(isOn: $enableAnimations) {
                        Label("动画效果", systemImage: "sparkles")
                    }
                } header: {
                    Text("交互")
                } footer: {
                    Text("触觉反馈会在操作时提供震动反馈，关闭可以节省电量")
                }
                
                // 高级设置
                Section {
                    NavigationLink {
                        AdvancedCustomizationView()
                    } label: {
                        Label("高级设置", systemImage: "gearshape.2.fill")
                    }
                } header: {
                    Text("更多")
                }
            }
            .navigationTitle("个性化")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 主题选择视图

struct ThemeSelectionView: View {
    @StateObject private var themeStore = ThemeStore.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                Text("选择您喜欢的主题")
                    .font(.title2.bold())
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                    ForEach(themeStore.availableThemes) { theme in
                        ThemePreviewCard(
                            theme: theme,
                            isSelected: themeStore.currentTheme.id == theme.id
                        ) {
                            themeStore.setTheme(theme)
                            HapticManager.shared.success()
                            
                            // 延迟关闭以显示效果
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("选择主题")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 高级定制视图

struct AdvancedCustomizationView: View {
    @AppStorage("cardStyle") private var cardStyle: CardStyle = .material
    @AppStorage("iconStyle") private var iconStyle: IconStyle = .filled
    @AppStorage("reduceTransparency") private var reduceTransparency = false
    
    enum CardStyle: String, CaseIterable {
        case material = "磨砂"
        case solid = "纯色"
        case gradient = "渐变"
    }
    
    enum IconStyle: String, CaseIterable {
        case filled = "填充"
        case outlined = "轮廓"
    }
    
    var body: some View {
        List {
            Section {
                Picker("卡片样式", selection: $cardStyle) {
                    ForEach(CardStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                
                // 预览
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("示例卡片")
                            .font(.headline)
                        Spacer()
                        Image(systemName: iconStyle == .filled ? "star.fill" : "star")
                    }
                    .padding()
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } header: {
                Text("卡片")
            }
            
            Section {
                Picker("图标样式", selection: $iconStyle) {
                    ForEach(IconStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
            } header: {
                Text("图标")
            }
            
            Section {
                Toggle(isOn: $reduceTransparency) {
                    Label("减少透明度", systemImage: "eye.fill")
                }
            } header: {
                Text("辅助功能")
            } footer: {
                Text("降低界面透明度，提高可读性")
            }
        }
        .navigationTitle("高级设置")
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch cardStyle {
        case .material:
            Rectangle()
                .fill(.ultraThinMaterial)
        case .solid:
            Rectangle()
                .fill(Color.gray.opacity(0.1))
        case .gradient:
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: "#667EEA").opacity(0.1), Color(hex: "#48C6EF").opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
    }
}

// MARK: - 布局定制视图

struct LayoutCustomizationView: View {
    @AppStorage("homeLayout") private var homeLayout: HomeLayout = .grid
    @AppStorage("cardSize") private var cardSize: CardSize = .medium
    
    enum HomeLayout: String, CaseIterable {
        case grid = "网格"
        case list = "列表"
        case compact = "紧凑"
    }
    
    enum CardSize: String, CaseIterable {
        case small = "小"
        case medium = "中"
        case large = "大"
    }
    
    var body: some View {
        List {
            Section {
                Picker("主页布局", selection: $homeLayout) {
                    ForEach(HomeLayout.allCases, id: \.self) { layout in
                        Text(layout.rawValue).tag(layout)
                    }
                }
                .pickerStyle(.segmented)
                
                // 预览
                layoutPreview
                    .frame(height: 150)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } header: {
                Text("布局")
            }
            
            Section {
                Picker("卡片大小", selection: $cardSize) {
                    ForEach(CardSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("大小")
            }
        }
        .navigationTitle("布局定制")
    }
    
    @ViewBuilder
    private var layoutPreview: some View {
        switch homeLayout {
        case .grid:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(0..<4) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.3))
                }
            }
            .padding()
        case .list:
            VStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.3))
                        .frame(height: 40)
                }
            }
            .padding()
        case .compact:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.3))
                }
            }
            .padding()
        }
    }
}

