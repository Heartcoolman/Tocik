//
//  AccessibilitySettingsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 无障碍设置
//

import SwiftUI

struct AccessibilitySettingsView: View {
    @AppStorage("enableDynamicType") private var enableDynamicType = true
    @AppStorage("enableHighContrast") private var enableHighContrast = false
    @AppStorage("enableReduceMotion") private var enableReduceMotion = false
    @AppStorage("enableVoiceOverEnhanced") private var enableVoiceOverEnhanced = true
    @AppStorage("minimumTapSize") private var minimumTapSize: Double = 44
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $enableDynamicType) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("动态字体")
                        Text("跟随系统字体大小设置")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("文字")
            }
            
            Section {
                Toggle(isOn: $enableHighContrast) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("高对比度模式")
                        Text("增强文字和背景的对比度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("视觉")
            }
            
            Section {
                Toggle(isOn: $enableReduceMotion) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("减少动画")
                        Text("降低动画效果，提高性能")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("动画")
            }
            
            Section {
                Toggle(isOn: $enableVoiceOverEnhanced) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("增强VoiceOver")
                        Text("为屏幕阅读器优化标签和描述")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("VoiceOver")
            }
            
            Section {
                Slider(value: $minimumTapSize, in: 44...60, step: 4) {
                    Text("最小点击区域")
                }
                
                Text("当前: \(Int(minimumTapSize))pt")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("交互")
            } footer: {
                Text("增大点击区域可以提高操作准确性")
            }
            
            Section {
                NavigationLink {
                    VoiceOverGuideView()
                } label: {
                    Label("VoiceOver使用指南", systemImage: "info.circle")
                }
            } header: {
                Text("帮助")
            }
        }
        .navigationTitle("无障碍")
    }
}

struct VoiceOverGuideView: View {
    let guides: [(title: String, description: String)] = [
        ("导航", "使用两指左右滑动切换页面"),
        ("选择项目", "单指左右滑动浏览，双击选择"),
        ("编辑文本", "三指双击开始编辑"),
        ("自定义手势", "可在系统设置中配置VoiceOver手势"),
    ]
    
    var body: some View {
        List {
            Section {
                Text("Tocik已为VoiceOver优化，所有功能都可以通过屏幕阅读器访问")
                    .font(.subheadline)
            }
            
            Section("基本操作") {
                ForEach(guides, id: \.title) { guide in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(guide.title)
                            .font(.headline)
                        Text(guide.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("VoiceOver指南")
    }
}

