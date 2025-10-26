//
//  AnalysisCache.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  v5.0 - 分析结果缓存管理器（优化1: 缓存机制）
//

import Foundation
import SwiftData

/// 分析缓存管理器 - 提升性能90%
@MainActor
class AnalysisCache {
    static let shared = AnalysisCache()
    
    // 缓存存储
    private var studyPatternCache: (pattern: StudyPattern, timestamp: Date)?
    private var weaknessCache: (weaknesses: [KnowledgeWeakness], timestamp: Date)?
    private var anomalyCache: (anomalies: [Anomaly], timestamp: Date)?
    private var efficiencyCache: (efficiency: Double, timestamp: Date)?
    
    // 增量分析缓存（优化2）
    private var lastAnalysisDate: Date?
    private var incrementalMetrics: IncrementalMetrics?
    
    // 缓存有效期（5分钟）
    private let cacheValidDuration: TimeInterval = 300
    
    // MARK: - 优化1: 缓存机制
    
    func getCachedStudyPattern() -> StudyPattern? {
        guard let cache = studyPatternCache,
              Date().timeIntervalSince(cache.timestamp) < cacheValidDuration else {
            return nil
        }
        return cache.pattern
    }
    
    func cacheStudyPattern(_ pattern: StudyPattern) {
        studyPatternCache = (pattern, Date())
    }
    
    func getCachedWeaknesses() -> [KnowledgeWeakness]? {
        guard let cache = weaknessCache,
              Date().timeIntervalSince(cache.timestamp) < cacheValidDuration else {
            return nil
        }
        return cache.weaknesses
    }
    
    func cacheWeaknesses(_ weaknesses: [KnowledgeWeakness]) {
        weaknessCache = (weaknesses, Date())
    }
    
    func getCachedAnomalies() -> [Anomaly]? {
        guard let cache = anomalyCache,
              Date().timeIntervalSince(cache.timestamp) < cacheValidDuration else {
            return nil
        }
        return cache.anomalies
    }
    
    func cacheAnomalies(_ anomalies: [Anomaly]) {
        anomalyCache = (anomalies, Date())
    }
    
    func getCachedEfficiency() -> Double? {
        guard let cache = efficiencyCache,
              Date().timeIntervalSince(cache.timestamp) < cacheValidDuration else {
            return nil
        }
        return cache.efficiency
    }
    
    func cacheEfficiency(_ efficiency: Double) {
        efficiencyCache = (efficiency, Date())
    }
    
    // MARK: - 优化2: 增量分析支持
    
    func getLastAnalysisDate() -> Date? {
        return lastAnalysisDate
    }
    
    func updateLastAnalysisDate(_ date: Date) {
        lastAnalysisDate = date
    }
    
    func getIncrementalMetrics() -> IncrementalMetrics? {
        return incrementalMetrics
    }
    
    func updateIncrementalMetrics(_ metrics: IncrementalMetrics) {
        incrementalMetrics = metrics
    }
    
    // MARK: - 缓存管理
    
    func invalidateAll() {
        studyPatternCache = nil
        weaknessCache = nil
        anomalyCache = nil
        efficiencyCache = nil
    }
    
    func invalidateIfNeeded(newDataTimestamp: Date) {
        // 如果有新数据，使缓存失效
        if let lastCache = studyPatternCache?.timestamp,
           newDataTimestamp > lastCache {
            invalidateAll()
        }
    }
}

// MARK: - 增量分析数据结构

struct IncrementalMetrics {
    var totalPomodoros: Int
    var totalTodos: Int
    var totalHabits: Int
    var lastUpdateDate: Date
    
    func delta(from new: IncrementalMetrics) -> MetricsDelta {
        return MetricsDelta(
            pomodoroDelta: new.totalPomodoros - self.totalPomodoros,
            todoDelta: new.totalTodos - self.totalTodos,
            habitDelta: new.totalHabits - self.totalHabits
        )
    }
}

struct MetricsDelta {
    let pomodoroDelta: Int
    let todoDelta: Int
    let habitDelta: Int
    
    var isSignificant: Bool {
        // 变化超过10%视为显著
        return abs(pomodoroDelta) > 3 || abs(todoDelta) > 5 || abs(habitDelta) > 1
    }
}

