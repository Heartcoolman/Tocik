//
//  AppCoordinator.swift
//  Tocik
//
//  Created: 2025/10/24
//  应用协调器 - 统一管理应用级别的初始化和生命周期
//

import Foundation
import SwiftData
import Combine
import os

/// 应用协调器 - 应用的核心协调器，管理所有子系统
@MainActor
class AppCoordinator: ObservableObject {
    
    // MARK: - 属性
    
    /// 数据库容器
    let container: ModelContainer
    
    /// 通知管理器
    let notificationManager = NotificationManager.shared
    
    /// 初始化状态
    @Published var isInitialized = false
    @Published var initializationProgress: Double = 0.0
    @Published var initializationMessage: String = ""
    
    // MARK: - 初始化
    
    init() {
        AppLogger.logAppLaunch()
        
        // 创建数据库容器
        self.container = DatabaseConfigurator.createContainer()
    }
    
    // MARK: - 应用初始化
    
    /// 执行完整的应用初始化流程
    func initialize() async {
        guard !isInitialized else {
            AppLogger.app.debug("应用已初始化，跳过")
            return
        }
        
        let startTime = Date()
        AppLogger.app.info("🚀 开始应用初始化流程...")
        
        // 步骤1: 启动优化（20%）
        await updateProgress(0.2, "预热分析引擎...")
        await performStartupOptimization()
        
        // 步骤2: 请求权限（40%）
        await updateProgress(0.4, "请求系统权限...")
        await requestPermissions()
        
        // 步骤3: 初始化子系统（60%）
        await updateProgress(0.6, "初始化系统组件...")
        await initializeSubsystems()
        
        // 步骤4: 数据验证（80%）
        await updateProgress(0.8, "验证数据完整性...")
        let isValid = await SystemInitializer.validateSystemData(context: container.mainContext)
        if !isValid {
            AppLogger.app.warning("⚠️ 数据验证发现问题，将尝试修复...")
            await SystemInitializer.initialize(context: container.mainContext)
        }
        
        // 步骤5: 完成（100%）
        await updateProgress(1.0, "初始化完成")
        isInitialized = true
        
        let duration = Date().timeIntervalSince(startTime)
        AppLogger.performance.info("✅ 应用初始化完成 - 总耗时: \(String(format: "%.2fs", duration))")
        
        logInitializationSummary()
    }
    
    // MARK: - 子步骤
    
    /// 执行启动优化
    private func performStartupOptimization() async {
        await AnalysisPreloader.warmup(context: container.mainContext)
        AppLogger.performance.info("✅ 分析引擎预热完成")
    }
    
    /// 请求必要权限
    private func requestPermissions() async {
        // 请求通知权限
        let granted = await notificationManager.requestAuthorization()
        if granted {
            AppLogger.app.info("✅ 通知权限已授予")
        } else {
            AppLogger.app.warning("⚠️ 通知权限未授予")
        }
    }
    
    /// 初始化所有子系统
    private func initializeSubsystems() async {
        await SystemInitializer.initialize(context: container.mainContext)
    }
    
    /// 更新初始化进度
    private func updateProgress(_ progress: Double, _ message: String) async {
        self.initializationProgress = progress
        self.initializationMessage = message
        AppLogger.app.debug("📊 初始化进度: \(Int(progress * 100))% - \(message)")
    }
    
    /// 记录初始化总结
    private func logInitializationSummary() {
        AppLogger.app.info("🎉 Tocik v5.0 初始化完成")
        AppLogger.app.info("📱 界面: StudyContentView")
        AppLogger.app.info("🤖 AI引擎: 混合分析模式")
        AppLogger.app.info("💾 数据库: SwiftData")
        AppLogger.app.info("✨ 状态: 就绪")
    }
    
    // MARK: - 应用生命周期
    
    /// 应用进入后台
    func didEnterBackground() {
        AppLogger.logAppBackground()
        // 执行后台任务
    }
    
    /// 应用恢复前台
    func willEnterForeground() {
        AppLogger.logAppForeground()
        // 刷新数据
    }
}

