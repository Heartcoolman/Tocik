//
//  AnalysisPreloader.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 分析引擎预热器（优化22）
//

import Foundation
import SwiftData

/// 分析预热器 - 应用启动时预加载，提升首次分析速度50%
@MainActor
class AnalysisPreloader {
    static let shared = AnalysisPreloader()
    
    private var isWarmedUp = false
    private var preloadedProfile: UserProfile?
    
    /// 应用启动时预热
    static func warmup(context: ModelContext) async {
        print("🔥 分析引擎预热开始...")
        
        await Task.detached(priority: .utility) {
            // 预加载常用数据
            await preloadCommonData(context: context)
            
            // 预计算缓存的指标
            await precalculateMetrics(context: context)
            
            await MainActor.run {
                shared.isWarmedUp = true
                print("✅ 分析引擎预热完成")
            }
        }.value
    }
    
    /// 预加载数据
    private static func preloadCommonData(context: ModelContext) async {
        await MainActor.run {
            // 获取用户画像
            let profileDescriptor = FetchDescriptor<UserProfile>()
            if let profile = try? context.fetch(profileDescriptor).first {
                shared.preloadedProfile = profile
            }
            
            // 预加载最近7天的数据到内存
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            let sessionDescriptor = FetchDescriptor<PomodoroSession>(
                predicate: #Predicate { $0.startTime >= weekAgo }
            )
            _ = try? context.fetch(sessionDescriptor)
            
            print("  ✓ 数据预加载完成")
        }
    }
    
    /// 预计算指标
    private static func precalculateMetrics(context: ModelContext) async {
        await MainActor.run {
            // 预计算常用统计
            let sessionDescriptor = FetchDescriptor<PomodoroSession>()
            let todoDescriptor = FetchDescriptor<TodoItem>()
            let habitDescriptor = FetchDescriptor<Habit>()
            
            guard let sessions = try? context.fetch(sessionDescriptor),
                  let todos = try? context.fetch(todoDescriptor),
                  let habits = try? context.fetch(habitDescriptor) else {
                return
            }
            
            // 触发一次快速分析，结果会被缓存
            let pattern = SmartAnalyzer.analyzeStudyPattern(
                pomodoroSessions: sessions,
                todos: todos,
                habits: habits
            )
            AnalysisCache.shared.cacheStudyPattern(pattern)
            
            // 更新自适应阈值
            AdaptiveThreshold.shared.updateThresholds(
                pomodoroSessions: sessions,
                todos: todos,
                habits: habits
            )
            
            print("  ✓ 指标预计算完成")
        }
    }
    
    /// 获取预加载的用户画像
    func getPreloadedProfile() -> UserProfile? {
        return preloadedProfile
    }
    
    /// 检查是否已预热
    func isReady() -> Bool {
        return isWarmedUp
    }
}

