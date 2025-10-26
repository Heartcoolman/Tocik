//
//  SystemInitializer.swift
//  Tocik
//
//  Created: 2025/10/24
//  系统初始化器 - 初始化成就、模板、用户画像等
//

import Foundation
import SwiftData
import os

/// 系统初始化器 - 负责初始化默认数据和系统组件
@MainActor
class SystemInitializer {
    
    /// 执行完整的系统初始化
    static func initialize(context: ModelContext) async {
        let startTime = Date()
        AppLogger.app.info("🚀 开始系统初始化...")
        
        // 1. 初始化成就系统
        await initializeAchievements(context: context)
        
        // 2. 初始化用户等级系统
        await initializeUserLevels(context: context)
        
        // 3. 初始化笔记模板
        await initializeNoteTemplates(context: context)
        
        // 4. 初始化用户画像
        await initializeUserProfile(context: context)
        
        // 5. 保存所有变更
        do {
            try context.save()
            let duration = Date().timeIntervalSince(startTime)
            AppLogger.database.info("✅ 系统初始化完成 - 耗时: \(String(format: "%.2fs", duration))")
        } catch {
            AppLogger.database.error("❌ 系统初始化保存失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 各子系统初始化
    
    /// 初始化成就系统
    private static func initializeAchievements(context: ModelContext) async {
        let descriptor = FetchDescriptor<Achievement>()
        guard let existingAchievements = try? context.fetch(descriptor),
              existingAchievements.isEmpty else {
            AppLogger.database.debug("成就系统已存在，跳过初始化")
            return
        }
        
        AchievementManager.initializeDefaultAchievements(context: context)
        AppLogger.database.info("✅ 成就系统初始化完成 - 创建17个成就")
    }
    
    /// 初始化用户等级系统
    private static func initializeUserLevels(context: ModelContext) async {
        let descriptor = FetchDescriptor<UserLevel>()
        guard let existingLevels = try? context.fetch(descriptor),
              existingLevels.isEmpty else {
            AppLogger.database.debug("用户等级系统已存在，跳过初始化")
            return
        }
        
        let userLevel = UserLevel()
        context.insert(userLevel)
        AppLogger.database.info("✅ 用户等级系统初始化完成")
    }
    
    /// 初始化笔记模板
    private static func initializeNoteTemplates(context: ModelContext) async {
        let descriptor = FetchDescriptor<NoteTemplate>()
        guard let existingTemplates = try? context.fetch(descriptor),
              existingTemplates.isEmpty else {
            AppLogger.database.debug("笔记模板已存在，跳过初始化")
            return
        }
        
        let templates = NoteTemplate.createBuiltInTemplates()
        for template in templates {
            context.insert(template)
        }
        AppLogger.database.info("✅ 笔记模板初始化完成 - 创建\(templates.count)个模板")
    }
    
    /// 初始化用户画像
    private static func initializeUserProfile(context: ModelContext) async {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let existingProfiles = try? context.fetch(descriptor),
              existingProfiles.isEmpty else {
            AppLogger.database.debug("用户画像已存在，跳过初始化")
            return
        }
        
        let userProfile = UserProfile()
        context.insert(userProfile)
        AppLogger.database.info("✅ 用户画像系统初始化完成")
    }
    
    // MARK: - 数据验证
    
    /// 验证系统数据完整性
    static func validateSystemData(context: ModelContext) async -> Bool {
        var isValid = true
        
        // 验证成就系统
        let achievementDescriptor = FetchDescriptor<Achievement>()
        if let achievements = try? context.fetch(achievementDescriptor) {
            if achievements.isEmpty {
                AppLogger.database.warning("⚠️ 成就系统未初始化")
                isValid = false
            }
        }
        
        // 验证用户画像
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let profiles = try? context.fetch(profileDescriptor) {
            if profiles.isEmpty {
                AppLogger.database.warning("⚠️ 用户画像未初始化")
                isValid = false
            }
        }
        
        return isValid
    }
}

