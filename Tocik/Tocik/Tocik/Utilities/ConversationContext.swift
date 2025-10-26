//
//  ConversationContext.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 对话上下文管理器（优化19）
//

import Foundation
import Combine

/// 对话上下文管理 - 支持多轮对话，AI更智能
@MainActor
class ConversationContext: ObservableObject {
    static let shared = ConversationContext()
    
    @Published var sessionHistory: [ConversationMessage] = []
    @Published var currentSession: String? // 会话ID
    
    // 语义上下文提取
    private var extractedContext: [String: Any] = [:]
    
    // 配置
    private let maxHistoryLength = 10 // 保留最近10轮对话
    private let contextSummaryLength = 3 // 压缩为最近3轮
    
    /// 带上下文的对话
    func chat(
        userMessage: String,
        deepSeekManager: DeepSeekManager,
        withContext: Bool = true
    ) async -> (response: String?, tokens: Int) {
        var enhancedMessage = userMessage
        
        if withContext && !sessionHistory.isEmpty {
            // 压缩历史为简短摘要
            let contextSummary = summarizeRecentHistory(last: contextSummaryLength)
            
            enhancedMessage = """
            [对话历史摘要]:
            \(contextSummary)
            
            [当前问题]:
            \(userMessage)
            """
        }
        
        // 调用API
        let (response, tokens) = await deepSeekManager.chatWithTokenTracking(userMessage: enhancedMessage)
        
        // 更新历史
        addToHistory(userMessage: userMessage, assistantResponse: response)
        
        // 提取关键信息
        if let response = response {
            extractSemanticContext(from: userMessage, and: response)
        }
        
        return (response, tokens)
    }
    
    /// 压缩历史对话
    private func summarizeRecentHistory(last n: Int) -> String {
        let recentMessages = sessionHistory.suffix(n * 2) // user + assistant 配对
        
        return recentMessages.map { msg in
            let preview = String(msg.content.prefix(80))
            return "\(msg.role == .user ? "用户" : "助手"): \(preview)\(msg.content.count > 80 ? "..." : "")"
        }.joined(separator: "\n")
    }
    
    /// 添加到历史
    private func addToHistory(userMessage: String, assistantResponse: String?) {
        sessionHistory.append(ConversationMessage(
            role: .user,
            content: userMessage,
            timestamp: Date()
        ))
        
        if let response = assistantResponse {
            sessionHistory.append(ConversationMessage(
                role: .assistant,
                content: response,
                timestamp: Date()
            ))
        }
        
        // 限制历史长度
        if sessionHistory.count > maxHistoryLength * 2 {
            sessionHistory.removeFirst(2) // 移除最早的一对
        }
    }
    
    /// 提取语义上下文（简单版）
    private func extractSemanticContext(from userMsg: String, and aiMsg: String) {
        // 提取科目名称
        let subjects = ["数学", "物理", "化学", "英语", "语文", "生物", "历史", "地理"]
        for subject in subjects {
            if userMsg.contains(subject) || aiMsg.contains(subject) {
                extractedContext["discussedSubject"] = subject
            }
        }
        
        // 提取意图
        if userMsg.contains("为什么") || userMsg.contains("原因") {
            extractedContext["intent"] = "causality"
        } else if userMsg.contains("如何") || userMsg.contains("怎么") {
            extractedContext["intent"] = "howto"
        }
    }
    
    /// 开始新会话
    func startNewSession() {
        currentSession = UUID().uuidString
        sessionHistory = []
        extractedContext = [:]
        print("🆕 开始新的对话会话")
    }
    
    /// 获取会话摘要（用于分析）
    func getSessionSummary() -> String {
        guard !sessionHistory.isEmpty else {
            return "无对话记录"
        }
        
        return "共\(sessionHistory.count / 2)轮对话，主要讨论：\(extractedContext["discussedSubject"] ?? "学习问题")"
    }
    
    /// 清理旧会话
    func cleanup() {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        sessionHistory.removeAll { $0.timestamp < oneDayAgo }
    }
}

// MARK: - 数据结构

struct ConversationMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum MessageRole {
        case user
        case assistant
    }
}

