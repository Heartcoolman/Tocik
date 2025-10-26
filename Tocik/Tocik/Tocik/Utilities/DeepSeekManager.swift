//
//  DeepSeekManager.swift
//  Tocik
//
//  AI智能体 - DeepSeek集成
//  专注于学习数据分析和个性化建议
//

import Foundation
import SwiftUI
import Combine
import os

/// DeepSeek AI 管理器
@MainActor
class DeepSeekManager: ObservableObject {
    static let shared = DeepSeekManager()
    
    @Published var isProcessing = false
    @Published var lastError: String?
    
    // API 配置
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    // API Key 从配置文件读取（安全）
    private let apiKey: String = {
        // 尝试从 Info.plist 读取（使用 xcconfig 配置）
        if let key = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String, !key.isEmpty {
            return key
        }
        // 备用：从环境变量读取
        if let key = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"], !key.isEmpty {
            return key
        }
        // 如果都没有配置，返回空字符串并在调用时报错
        AppLogger.network.warning("⚠️ DeepSeek API密钥未配置！请在Config.xcconfig中设置DEEPSEEK_API_KEY")
        return ""
    }()
    
    // 系统提示词 - 定义智能体的角色和能力
    private let systemPrompt = """
    你是 Tocik 学习助手，一个专业的学习数据分析和个性化建议智能体。
    
    ## 你的角色定位
    - 学习效率分析专家
    - 个性化学习计划设计师
    - 时间管理顾问
    - 知识掌握度评估师
    
    ## 核心能力
    1. **数据洞察**：深度分析学习数据，发现隐藏的模式和趋势
    2. **个性化建议**：基于用户的学习习惯和目标，提供针对性建议
    3. **问题诊断**：识别学习中的瓶颈和问题，提出解决方案
    4. **激励引导**：用积极、鼓励的语言，帮助用户保持学习动力
    
    ## 分析维度
    - 学习时长分布（最佳学习时段、专注度波动）
    - 任务完成情况（完成率、拖延模式、优先级管理）
    - 知识掌握度（错题分析、复习效果、遗忘曲线）
    - 习惯坚持性（连续性、中断原因、改进建议）
    - 目标达成率（进度评估、时间预测、调整建议）
    
    ## 回答风格
    - 专业但不生硬，像一个资深学长/学姐
    - 数据驱动，用具体数字说话
    - 结构清晰，分点阐述
    - 既指出问题，也给出解决方案
    - 适度使用 emoji 增加亲和力（但不要过多）
    
    ## 回答格式
    每次分析包含：
    1. 📊 数据概览（关键指标总结）
    2. 💡 核心洞察（3-5条最重要的发现）
    3. ⚠️ 需要关注的问题（如有）
    4. ✨ 个性化建议（3-5条具体可行的建议）
    5. 🎯 下一步行动（优先级排序的行动清单）
    
    ## 注意事项
    - 永远基于数据事实，不臆测
    - 建议要具体、可执行，避免泛泛而谈
    - 考虑用户的实际情况（学业压力、时间限制等）
    - 鼓励为主，批评为辅
    - 如果数据不足，明确指出并建议如何改进数据收集
    """
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 分析学习数据
    func analyzeStudyData(
        pomodoroCount: Int,
        completedTodos: Int,
        totalTodos: Int,
        studyHours: Double,
        habitStreak: Int,
        recentPattern: String
    ) async -> String? {
        let userMessage = """
        请分析我的学习数据：
        
        📚 本周数据
        - 完成番茄钟：\(pomodoroCount) 个
        - 待办完成：\(completedTodos)/\(totalTodos)
        - 学习时长：\(String(format: "%.1f", studyHours)) 小时
        - 习惯连续：\(habitStreak) 天
        
        📈 最近趋势
        \(recentPattern)
        
        请给我专业的分析和建议。
        """
        
        return await chat(userMessage: userMessage)
    }
    
    /// 诊断学习问题
    func diagnoseProblems(
        issues: [String],
        context: String
    ) async -> String? {
        let userMessage = """
        我遇到了以下学习问题：
        \(issues.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        背景信息：
        \(context)
        
        请帮我分析原因并提供解决方案。
        """
        
        return await chat(userMessage: userMessage)
    }
    
    /// 制定学习计划
    func createStudyPlan(
        goals: [String],
        availableTime: String,
        currentLevel: String
    ) async -> String? {
        let userMessage = """
        我想制定一个学习计划：
        
        🎯 学习目标
        \(goals.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        ⏰ 可用时间：\(availableTime)
        📊 当前水平：\(currentLevel)
        
        请帮我设计一个可行的学习计划。
        """
        
        return await chat(userMessage: userMessage)
    }
    
    /// 基于数据摘要的深度分析
    func analyzeWithDigest(digest: DataDigest, userProfile: UserProfile?) async -> (response: String?, tokens: Int) {
        let prompt = digest.generateAIPrompt()
        let (response, tokens) = await chatWithTokenTracking(userMessage: prompt)
        
        // 记录token消耗
        if let profile = userProfile, tokens > 0 {
            await MainActor.run {
                profile.recordTokenUsage(tokens: tokens, callType: .analysis)
            }
        }
        
        return (response, tokens)
    }
    
    /// 自由对话
    func chat(userMessage: String) async -> String? {
        let (response, _) = await chatWithTokenTracking(userMessage: userMessage)
        return response
    }
    
    /// 带Token追踪的对话
    func chatWithTokenTracking(userMessage: String) async -> (response: String?, tokens: Int) {
        isProcessing = true
        lastError = nil
        
        defer { isProcessing = false }
        
        do {
            // 使用弹性客户端（优化18: 重试与熔断）
            let result = try await ResilientAPIClient.shared.callWithRetry {
                try await self.makeAPIRequestWithTokens(userMessage: userMessage)
            }
            return result
        } catch {
            lastError = error.localizedDescription
            return (nil, 0)
        }
    }
    
    /// 优化16: JSON结构化输出
    func chatWithStructuredOutput(userMessage: String) async -> (response: StructuredAnalysisResponse?, tokens: Int) {
        isProcessing = true
        lastError = nil
        
        defer { isProcessing = false }
        
        do {
            let result = try await ResilientAPIClient.shared.callWithRetry {
                try await self.makeStructuredAPIRequest(userMessage: userMessage)
            }
            return result
        } catch {
            lastError = error.localizedDescription
            return (nil, 0)
        }
    }
    
    /// 优化23: 流式响应
    func chatWithStreaming(
        userMessage: String,
        onChunk: @escaping (String) -> Void
    ) async -> Int {
        isProcessing = true
        lastError = nil
        
        defer { isProcessing = false }
        
        do {
            let tokens = try await makeStreamingRequest(
                userMessage: userMessage,
                onChunk: onChunk
            )
            return tokens
        } catch {
            lastError = error.localizedDescription
            return 0
        }
    }
    
    // MARK: - Private Methods
    
    private func makeAPIRequest(userMessage: String) async throws -> String {
        let (response, _) = try await makeAPIRequestWithTokens(userMessage: userMessage)
        return response
    }
    
    private func makeAPIRequestWithTokens(userMessage: String) async throws -> (String, Int) {
        guard let url = URL(string: baseURL) else {
            throw DeepSeekError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 2000,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeepSeekError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw DeepSeekError.apiError(errorMessage.error.message)
            }
            throw DeepSeekError.httpError(httpResponse.statusCode)
        }
        
        let responseData = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        guard let content = responseData.choices.first?.message.content else {
            throw DeepSeekError.emptyResponse
        }
        
        // 提取token使用量
        let totalTokens = responseData.usage?.totalTokens ?? 0
        
        return (content, totalTokens)
    }
    
    // MARK: - API Key Management
    
    /// API Key 已内置，始终返回 true
    func hasAPIKey() -> Bool {
        return true
    }
    
    // MARK: - 优化16: JSON结构化请求
    
    private func makeStructuredAPIRequest(userMessage: String) async throws -> (StructuredAnalysisResponse, Int) {
        guard let url = URL(string: baseURL) else {
            throw DeepSeekError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 强制JSON输出
        let structuredSystemPrompt = """
        \(systemPrompt)
        
        你必须以JSON格式回复，严格遵循以下格式：
        {
            "analysis": "总体分析摘要",
            "suggestions": [
                {
                    "title": "建议标题",
                    "content": "详细内容",
                    "priority": "high|medium|low",
                    "category": "efficiency|habit|learning|motivation|rest",
                    "estimatedImpact": 0.8,
                    "actionSteps": ["步骤1", "步骤2"]
                }
            ],
            "keyInsights": ["洞察1", "洞察2"],
            "predictions": {
                "nextWeekTrend": "improving|stable|declining",
                "riskAreas": ["风险点1", "风险点2"]
            }
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": structuredSystemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 2000,
            "response_format": ["type": "json_object"], // 强制JSON
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DeepSeekError.invalidResponse
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        let totalTokens = chatResponse.usage?.totalTokens ?? 0
        
        // 解析JSON内容
        guard let content = chatResponse.choices.first?.message.content,
              let contentData = content.data(using: .utf8) else {
            throw DeepSeekError.emptyResponse
        }
        
        let structured = try JSONDecoder().decode(StructuredAnalysisResponse.self, from: contentData)
        
        return (structured, totalTokens)
    }
    
    // MARK: - 优化23: 流式请求
    
    private func makeStreamingRequest(
        userMessage: String,
        onChunk: @escaping (String) -> Void
    ) async throws -> Int {
        guard let url = URL(string: baseURL) else {
            throw DeepSeekError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.7,
            "max_tokens": 2000,
            "stream": true // 开启流式
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (bytes, _) = try await URLSession.shared.bytes(for: request)
        
        var totalTokens = 0
        var fullContent = ""
        
        for try await line in bytes.lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                
                if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                    break
                }
                
                if let data = jsonString.data(using: .utf8),
                   let streamChunk = try? JSONDecoder().decode(StreamChunk.self, from: data),
                   let delta = streamChunk.choices.first?.delta.content {
                    fullContent += delta
                    await MainActor.run {
                        onChunk(delta) // 实时回调
                    }
                }
                
                // 提取token（在最后一个chunk中）
                if let data = jsonString.data(using: .utf8),
                   let streamChunk = try? JSONDecoder().decode(StreamChunk.self, from: data),
                   let usage = streamChunk.usage {
                    totalTokens = usage.totalTokens
                }
            }
        }
        
        return totalTokens
    }
}

// MARK: - 优化16: 结构化响应模型

struct StructuredAnalysisResponse: Codable {
    let analysis: String
    let suggestions: [StructuredSuggestion]
    let keyInsights: [String]
    let predictions: PredictionData
    
    struct StructuredSuggestion: Codable {
        let title: String
        let content: String
        let priority: String
        let category: String
        let estimatedImpact: Double
        let actionSteps: [String]
    }
    
    struct PredictionData: Codable {
        let nextWeekTrend: String
        let riskAreas: [String]
    }
}

// MARK: - 优化23: 流式响应模型

struct StreamChunk: Codable {
    let choices: [StreamChoice]
    let usage: ChatResponse.Usage?
    
    struct StreamChoice: Codable {
        let delta: Delta
    }
    
    struct Delta: Codable {
        let content: String?
    }
}

// MARK: - Models

struct ChatResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct ErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
    }
}

enum DeepSeekError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case emptyResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 API 地址"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP 错误: \(code)"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .emptyResponse:
            return "收到空响应"
        }
    }
}

