//
//  ResilientAPIClient.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 弹性API客户端（优化18）
//

import Foundation

/// 弹性API客户端 - 自动重试、熔断保护、降级处理
@MainActor
class ResilientAPIClient {
    static let shared = ResilientAPIClient()
    
    // 熔断器状态
    private var failureCount = 0
    private var isCircuitOpen = false
    private var circuitOpenTime: Date?
    private var lastSuccessTime: Date?
    
    // 健康评分（用于降级决策）
    private(set) var healthScore: Double = 1.0
    
    // 配置
    private let maxRetries = 3
    private let circuitOpenThreshold = 5 // 连续失败5次打开熔断器
    private let circuitRecoveryTime: TimeInterval = 300 // 5分钟后尝试恢复
    
    /// 带重试的API调用
    func callWithRetry<T>(
        operation: @escaping () async throws -> T,
        onRetry: ((Int, Error) -> Void)? = nil
    ) async throws -> T {
        // 熔断器检查
        if isCircuitOpen {
            // 检查是否可以恢复
            if let openTime = circuitOpenTime,
               Date().timeIntervalSince(openTime) > circuitRecoveryTime {
                // 尝试半开状态
                isCircuitOpen = false
                print("🔄 熔断器半开，尝试恢复...")
            } else {
                throw APIError.circuitBreakerOpen
            }
        }
        
        var lastError: Error?
        
        // 指数退避重试
        for attempt in 0..<maxRetries {
            do {
                let result = try await operation()
                
                // 成功：重置失败计数，更新健康分数
                handleSuccess()
                
                return result
                
            } catch {
                lastError = error
                
                // 回调通知重试
                onRetry?(attempt + 1, error)
                
                // 最后一次尝试，不再等待
                if attempt < maxRetries - 1 {
                    let delay = pow(2.0, Double(attempt)) // 1s, 2s, 4s
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        // 所有重试失败
        handleFailure(error: lastError!)
        throw lastError!
    }
    
    /// 带超时的API调用
    func callWithTimeout<T>(
        timeout: TimeInterval = 30,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // 实际操作
            group.addTask {
                return try await self.callWithRetry(operation: operation)
            }
            
            // 超时控制
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw APIError.timeout
            }
            
            // 返回第一个完成的
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - 熔断器管理
    
    private func handleSuccess() {
        failureCount = 0
        lastSuccessTime = Date()
        
        // 恢复健康分数
        healthScore = min(healthScore + 0.1, 1.0)
        
        print("✅ API调用成功，健康分数：\(String(format: "%.2f", healthScore))")
    }
    
    private func handleFailure(error: Error) {
        failureCount += 1
        
        // 降低健康分数
        healthScore = max(healthScore - 0.2, 0.0)
        
        print("⚠️ API调用失败(\(failureCount)/\(circuitOpenThreshold))，健康分数：\(String(format: "%.2f", healthScore))")
        
        // 达到阈值，打开熔断器
        if failureCount >= circuitOpenThreshold {
            isCircuitOpen = true
            circuitOpenTime = Date()
            
            print("🔴 熔断器打开，\(Int(circuitRecoveryTime/60))分钟后自动恢复")
            
            // 自动恢复任务
            Task.detached { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64((self?.circuitRecoveryTime ?? 300) * 1_000_000_000))
                guard let self = self else { return }
                await MainActor.run {
                    self.attemptRecovery()
                }
            }
        }
    }
    
    private func attemptRecovery() {
        if isCircuitOpen {
            isCircuitOpen = false
            failureCount = max(failureCount - 2, 0) // 减少失败计数
            print("🟡 熔断器尝试恢复...")
        }
    }
    
    /// 手动重置熔断器
    func reset() {
        failureCount = 0
        isCircuitOpen = false
        circuitOpenTime = nil
        healthScore = 1.0
        print("🔄 熔断器已重置")
    }
    
    /// 获取系统状态
    func getSystemContext() -> SystemContext {
        return SystemContext(
            isNetworkAvailable: checkNetworkAvailability(),
            apiHealthScore: healthScore,
            lastAnalysisDate: lastSuccessTime,
            userPrefersFastResponse: false // 可从用户设置读取
        )
    }
    
    private func checkNetworkAvailability() -> Bool {
        // 简单检查，实际可用Reachability库
        return true // 后续可增强
    }
}

// MARK: - 错误定义

enum APIError: LocalizedError {
    case circuitBreakerOpen
    case timeout
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .circuitBreakerOpen:
            return "服务暂时不可用，请稍后重试"
        case .timeout:
            return "请求超时"
        case .maxRetriesExceeded:
            return "多次重试失败"
        }
    }
}

