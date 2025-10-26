//
//  NoteTemplate.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 笔记模板系统
//

import Foundation
import SwiftData

@Model
final class NoteTemplate {
    var id: UUID
    var name: String
    var templateDescription: String
    var content: String // Markdown模板内容
    var category: TemplateCategory
    var icon: String
    var colorHex: String
    var isBuiltIn: Bool // 是否为内置模板
    var createdDate: Date
    var usageCount: Int
    
    enum TemplateCategory: String, Codable, CaseIterable {
        case meeting = "会议纪要"
        case reading = "读书笔记"
        case course = "课堂笔记"
        case daily = "每日日记"
        case plan = "计划方案"
        case custom = "自定义"
        
        var defaultIcon: String {
            switch self {
            case .meeting: return "person.3.fill"
            case .reading: return "book.fill"
            case .course: return "graduationcap.fill"
            case .daily: return "calendar"
            case .plan: return "checklist"
            case .custom: return "doc.text.fill"
            }
        }
    }
    
    init(name: String, templateDescription: String = "", content: String, category: TemplateCategory, icon: String? = nil, colorHex: String = "#4A90E2", isBuiltIn: Bool = false) {
        self.id = UUID()
        self.name = name
        self.templateDescription = templateDescription
        self.content = content
        self.category = category
        self.icon = icon ?? category.defaultIcon
        self.colorHex = colorHex
        self.isBuiltIn = isBuiltIn
        self.createdDate = Date()
        self.usageCount = 0
    }
    
    // 内置模板
    static func createBuiltInTemplates() -> [NoteTemplate] {
        return [
            NoteTemplate(
                name: "会议纪要",
                templateDescription: "记录会议要点",
                content: """
                # 会议主题
                
                ## 基本信息
                - 时间：
                - 地点：
                - 参与人：
                
                ## 讨论要点
                1. 
                2. 
                3. 
                
                ## 决议事项
                - [ ] 
                - [ ] 
                
                ## 后续跟进
                
                """,
                category: .meeting,
                colorHex: "#4ECDC4",
                isBuiltIn: true
            ),
            NoteTemplate(
                name: "读书笔记",
                templateDescription: "记录阅读心得",
                content: """
                # 书名
                
                **作者**：
                **出版社**：
                **阅读日期**：
                
                ## 核心观点
                
                ## 精彩摘录
                > 
                
                ## 个人思考
                
                ## 评分
                ⭐️⭐️⭐️⭐️⭐️
                
                """,
                category: .reading,
                colorHex: "#A78BFA",
                isBuiltIn: true
            ),
            NoteTemplate(
                name: "课堂笔记",
                templateDescription: "记录课程内容",
                content: """
                # 课程名称
                
                **日期**：
                **教师**：
                
                ## 本节重点
                
                ## 详细笔记
                
                ### 知识点1
                
                ### 知识点2
                
                ## 问题思考
                - 
                
                ## 课后作业
                - [ ] 
                
                """,
                category: .course,
                colorHex: "#FFD93D",
                isBuiltIn: true
            ),
            NoteTemplate(
                name: "每日回顾",
                templateDescription: "记录每日总结",
                content: """
                # 📅 日期
                
                ## 今日完成
                - ✅ 
                - ✅ 
                
                ## 今日学习
                
                ## 今日反思
                
                ## 明日计划
                - [ ] 
                - [ ] 
                
                ## 心情
                😊 / 😐 / 😔
                
                """,
                category: .daily,
                colorHex: "#FF6B6B",
                isBuiltIn: true
            )
        ]
    }
}

