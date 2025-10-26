//
//  AppLogger.swift
//  Tocik
//
//  Created: 2025/10/24
//  统一日志系统 - 替代 print()
//

import Foundation
import os.log

/// 应用日志管理器 - 使用 os.log 进行专业日志管理
enum AppLogger {
    
    // MARK: - 日志分类
    
    /// 应用生命周期和系统事件
    static let app = Logger(subsystem: subsystem, category: "App")
    
    /// 网络请求和API调用
    static let network = Logger(subsystem: subsystem, category: "Network")
    
    /// 数据库操作
    static let database = Logger(subsystem: subsystem, category: "Database")
    
    /// AI分析和建议生成
    static let ai = Logger(subsystem: subsystem, category: "AI")
    
    /// 性能分析和优化
    static let performance = Logger(subsystem: subsystem, category: "Performance")
    
    /// 用户行为分析
    static let analytics = Logger(subsystem: subsystem, category: "Analytics")
    
    /// UI交互和视图生命周期
    static let ui = Logger(subsystem: subsystem, category: "UI")
    
    /// 数据导入导出
    static let dataSync = Logger(subsystem: subsystem, category: "DataSync")
    
    // MARK: - 配置
    
    private static let subsystem = "com.tocik.app"
    
    // MARK: - 便捷方法
    
    /// 记录应用启动
    static func logAppLaunch() {
        app.info("🚀 Tocik 应用启动")
    }
    
    /// 记录应用进入后台
    static func logAppBackground() {
        app.info("💤 应用进入后台")
    }
    
    /// 记录应用恢复前台
    static func logAppForeground() {
        app.info("👋 应用恢复前台")
    }
    
    /// 记录API请求
    static func logAPIRequest(endpoint: String) {
        network.debug("📤 API请求: \(endpoint)")
    }
    
    /// 记录API响应
    static func logAPIResponse(endpoint: String, statusCode: Int, duration: TimeInterval) {
        network.info("📥 API响应: \(endpoint) - \(statusCode) - \(String(format: "%.2fs", duration))")
    }
    
    /// 记录API错误
    static func logAPIError(endpoint: String, error: Error) {
        network.error("❌ API错误: \(endpoint) - \(error.localizedDescription)")
    }
    
    /// 记录数据库操作
    static func logDatabaseOperation(_ operation: String, duration: TimeInterval? = nil) {
        if let duration = duration {
            database.debug("💾 数据库: \(operation) - \(String(format: "%.3fs", duration))")
        } else {
            database.debug("💾 数据库: \(operation)")
        }
    }
    
    /// 记录AI分析开始
    static func logAIAnalysisStart(type: String) {
        ai.info("🤖 AI分析开始: \(type)")
    }
    
    /// 记录AI分析完成
    static func logAIAnalysisComplete(type: String, tokens: Int, duration: TimeInterval) {
        ai.info("✅ AI分析完成: \(type) - \(tokens) tokens - \(String(format: "%.2fs", duration))")
    }
    
    /// 记录性能指标
    static func logPerformance(metric: String, value: Double, unit: String) {
        performance.info("📊 性能: \(metric) = \(String(format: "%.2f", value)) \(unit)")
    }
    
    /// 记录用户行为
    static func logUserAction(_ action: String, parameters: [String: Any]? = nil) {
        if let params = parameters {
            analytics.info("👤 用户行为: \(action) - \(params)")
        } else {
            analytics.info("👤 用户行为: \(action)")
        }
    }
    
    /// 记录视图显示
    static func logViewAppear(_ viewName: String) {
        ui.debug("📱 视图显示: \(viewName)")
    }
    
    /// 记录视图消失
    static func logViewDisappear(_ viewName: String) {
        ui.debug("📱 视图消失: \(viewName)")
    }
    
    /// 记录数据导入
    static func logDataImport(source: String, count: Int) {
        dataSync.info("📥 数据导入: \(source) - \(count) 条记录")
    }
    
    /// 记录数据导出
    static func logDataExport(destination: String, count: Int) {
        dataSync.info("📤 数据导出: \(destination) - \(count) 条记录")
    }
    
    // MARK: - 错误和警告
    
    /// 记录通用错误
    static func logError(category: LogCategory, message: String, error: Error? = nil) {
        let logger = loggerFor(category)
        if let error = error {
            logger.error("❌ \(message): \(error.localizedDescription)")
        } else {
            logger.error("❌ \(message)")
        }
    }
    
    /// 记录警告
    static func logWarning(category: LogCategory, message: String) {
        let logger = loggerFor(category)
        logger.warning("⚠️ \(message)")
    }
    
    /// 记录调试信息
    static func logDebug(category: LogCategory, message: String) {
        let logger = loggerFor(category)
        logger.debug("🐛 \(message)")
    }
    
    // MARK: - 辅助方法
    
    private static func loggerFor(_ category: LogCategory) -> Logger {
        switch category {
        case .app: return app
        case .network: return network
        case .database: return database
        case .ai: return ai
        case .performance: return performance
        case .analytics: return analytics
        case .ui: return ui
        case .dataSync: return dataSync
        }
    }
}

/// 日志分类枚举
enum LogCategory {
    case app
    case network
    case database
    case ai
    case performance
    case analytics
    case ui
    case dataSync
}

// MARK: - 向后兼容的打印函数（逐步迁移）

/// 临时的过渡函数 - 逐步替换为 AppLogger
func logPrint(_ message: String, category: LogCategory = .app) {
    let logger = Logger(subsystem: "com.tocik.app", category: category.description)
    logger.info("\(message)")
}

extension LogCategory: CustomStringConvertible {
    var description: String {
        switch self {
        case .app: return "App"
        case .network: return "Network"
        case .database: return "Database"
        case .ai: return "AI"
        case .performance: return "Performance"
        case .analytics: return "Analytics"
        case .ui: return "UI"
        case .dataSync: return "DataSync"
        }
    }
}

