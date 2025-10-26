//
//  KeyboardShortcutsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 键盘快捷键（iPad优化）
//

import SwiftUI
import Combine

struct KeyboardShortcutsView: View {
    let shortcuts: [ShortcutCategory] = [
        ShortcutCategory(
            name: "导航",
            shortcuts: [
                Shortcut(key: "⌘ + 1", action: "切换到番茄钟"),
                Shortcut(key: "⌘ + 2", action: "切换到待办"),
                Shortcut(key: "⌘ + 3", action: "切换到课程表"),
                Shortcut(key: "⌘ + 4", action: "切换到笔记"),
                Shortcut(key: "⌘ + H", action: "返回主页"),
            ]
        ),
        ShortcutCategory(
            name: "操作",
            shortcuts: [
                Shortcut(key: "⌘ + N", action: "新建项目"),
                Shortcut(key: "⌘ + S", action: "保存"),
                Shortcut(key: "⌘ + F", action: "搜索"),
                Shortcut(key: "⌘ + ,", action: "设置"),
                Shortcut(key: "⌘ + Z", action: "撤销"),
            ]
        ),
        ShortcutCategory(
            name: "番茄钟",
            shortcuts: [
                Shortcut(key: "空格", action: "开始/暂停"),
                Shortcut(key: "⌘ + R", action: "重置"),
                Shortcut(key: "⌘ + I", action: "查看洞察"),
            ]
        ),
        ShortcutCategory(
            name: "编辑",
            shortcuts: [
                Shortcut(key: "⌘ + B", action: "加粗"),
                Shortcut(key: "⌘ + I", action: "斜体"),
                Shortcut(key: "⌘ + K", action: "插入链接"),
                Shortcut(key: "⌘ + ⇧ + V", action: "查看版本历史"),
            ]
        ),
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(shortcuts, id: \.name) { category in
                    Section(category.name) {
                        ForEach(category.shortcuts, id: \.key) { shortcut in
                            ShortcutRow(shortcut: shortcut)
                        }
                    }
                }
            }
            .navigationTitle("键盘快捷键")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ShortcutCategory {
    let name: String
    let shortcuts: [Shortcut]
}

struct Shortcut {
    let key: String
    let action: String
}

struct ShortcutRow: View {
    let shortcut: Shortcut
    
    var body: some View {
        HStack {
            Text(shortcut.action)
                .font(.subheadline)
            
            Spacer()
            
            Text(shortcut.key)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - 快捷键处理器

class KeyboardShortcutHandler: ObservableObject {
    static let shared = KeyboardShortcutHandler()
    
    @Published var currentAction: ShortcutAction?
    
    enum ShortcutAction {
        case newItem
        case save
        case search
        case settings
        case undo
        case startPomodoro
        case switchTab(Int)
    }
    
    private init() {
        setupKeyCommands()
    }
    
    private func setupKeyCommands() {
        // 在实际应用中，这里会注册UIKeyCommand
    }
    
    func handle(_ action: ShortcutAction) {
        currentAction = action
        HapticManager.shared.light()
    }
}

