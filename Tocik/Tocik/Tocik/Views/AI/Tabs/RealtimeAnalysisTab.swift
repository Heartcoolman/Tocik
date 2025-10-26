//
//  RealtimeAnalysisTab.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  实时分析标签页
//

import SwiftUI

struct RealtimeAnalysisTab: View {
    let analysisProgress: AIAssistantView.AnalysisProgress
    let streamingText: String
    let triggerConditions: [(title: String, isMet: Bool, description: String)]
    let onAnalyze: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 分析状态卡片
                AnalysisStatusCard(progress: analysisProgress)
                
                // 智能触发条件
                TriggerConditionsCard(conditions: triggerConditions)
                
                // 流式AI响应（如果有）
                if !streamingText.isEmpty {
                    EnhancedStreamingResponseCard(text: streamingText)
                }
                
                // 分析按钮
                AnalyzeButton(
                    isAnalyzing: analysisProgress == .aiAnalyzing || analysisProgress == .localAnalyzing,
                    onAnalyze: onAnalyze
                )
            }
            .padding()
        }
    }
}

// 分析状态卡片
struct AnalysisStatusCard: View {
    let progress: AIAssistantView.AnalysisProgress
    
    var body: some View {
        VStack(spacing: Theme.spacing.medium) {
            // 状态图标
            ZStack {
                Circle()
                    .fill(statusGradient.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(statusGradient)
                    .symbolEffect(.pulse, isActive: isAnimating)
            }
            
            Text(statusText)
                .font(.title3.bold())
            
            Text(statusDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if progress == .localAnalyzing || progress == .aiAnalyzing {
                ProgressView()
                    .tint(Theme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.largeCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var statusIcon: String {
        switch progress {
        case .idle: return "sparkles.rectangle.stack"
        case .localAnalyzing: return "cpu"
        case .aiAnalyzing: return "brain.head.profile"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch progress {
        case .idle: return "准备就绪"
        case .localAnalyzing: return "本地分析中..."
        case .aiAnalyzing: return "AI深度分析中..."
        case .completed: return "分析完成"
        }
    }
    
    private var statusDescription: String {
        switch progress {
        case .idle: return "点击下方按钮开始分析"
        case .localAnalyzing: return "正在进行快速本地分析"
        case .aiAnalyzing: return "AI正在深度分析您的学习数据"
        case .completed: return "查看下方的分析结果"
        }
    }
    
    private var statusGradient: LinearGradient {
        switch progress {
        case .idle: return Theme.primaryGradient
        case .localAnalyzing: return Theme.statsGradient
        case .aiAnalyzing: return Theme.primaryGradient
        case .completed: return Theme.habitGradient
        }
    }
    
    private var isAnimating: Bool {
        progress == .localAnalyzing || progress == .aiAnalyzing
    }
}

// 触发条件卡片
struct TriggerConditionsCard: View {
    let conditions: [(title: String, isMet: Bool, description: String)]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("智能触发条件")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "info.circle")
                        .foregroundColor(Theme.primaryColor)
                }
            }
            
            ForEach(Array(conditions.enumerated()), id: \.offset) { index, condition in
                ConditionRow(
                    title: condition.title,
                    isMet: condition.isMet,
                    description: condition.description,
                    showDescription: isExpanded
                )
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
}

struct ConditionRow: View {
    let title: String
    let isMet: Bool
    let description: String
    let showDescription: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundColor(isMet ? .green : .gray)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isMet ? .primary : .secondary)
                
                Spacer()
            }
            
            if showDescription {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 28)
            }
        }
    }
}

// 增强的流式响应卡片
struct EnhancedStreamingResponseCard: View {
    let text: String
    @State private var isExpanded = true
    @State private var showCopyConfirmation = false
    
    private var cleanedText: String {
        var cleaned = text
        cleaned = cleaned.replacingOccurrences(of: "**", with: "")
        cleaned = cleaned.replacingOccurrences(of: "__", with: "")
        cleaned = cleaned.replacingOccurrences(of: "*", with: "")
        cleaned = cleaned.replacingOccurrences(of: "_", with: "")
        cleaned = cleaned.replacingOccurrences(of: "##", with: "")
        cleaned = cleaned.replacingOccurrences(of: "#", with: "")
        cleaned = cleaned.replacingOccurrences(of: "- ", with: "")
        cleaned = cleaned.replacingOccurrences(of: "* ", with: "")
        cleaned = cleaned.replacingOccurrences(of: "+ ", with: "")
        cleaned = cleaned.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Label("AI实时分析", systemImage: "brain.head.profile")
                    .font(.headline)
                    .foregroundStyle(Theme.primaryGradient)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: copyText) {
                        Image(systemName: showCopyConfirmation ? "checkmark" : "doc.on.doc")
                            .foregroundColor(showCopyConfirmation ? .green : .secondary)
                    }
                    
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if isExpanded {
                Text(cleanedText)
                    .font(.body)
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .lineLimit(nil)
                
                // 打字机效果指示器
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Theme.primaryColor)
                                .frame(width: 6, height: 6)
                                .opacity(0.8)
                                .scaleEffect(1.0)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: UUID()
                                )
                        }
                    }
                }
            }
        }
        .padding(Theme.spacing.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.largeCornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func copyText() {
        UIPasteboard.general.string = cleanedText
        withAnimation {
            showCopyConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyConfirmation = false
            }
        }
        HapticManager.shared.success()
    }
}

// 分析按钮
struct AnalyzeButton: View {
    let isAnalyzing: Bool
    let onAnalyze: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onAnalyze) {
            HStack(spacing: 12) {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)
                    Text("分析中...")
                        .font(.headline)
                } else {
                    Image(systemName: "sparkles")
                        .font(.title3)
                    Text("开始AI分析")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Theme.primaryColor.opacity(0.3), radius: isPulsing ? 20 : 10, y: 5)
            .scaleEffect(isPulsing ? 1.02 : 1.0)
        }
        .disabled(isAnalyzing)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    RealtimeAnalysisTab(
        analysisProgress: .completed,
        streamingText: "根据您最近7天的学习数据分析，我发现以下几点：\n\n1. 您的专注度在早晨最高\n2. 建议减少晚间学习时长\n3. 数学科目需要加强练习",
        triggerConditions: [
            ("距离上次分析超过3天", true, "上次分析：5天前"),
            ("本周数据量充足", true, "本周已完成 15 个番茄钟"),
            ("检测到学习异常", false, "暂未检测到异常")
        ],
        onAnalyze: {}
    )
}

