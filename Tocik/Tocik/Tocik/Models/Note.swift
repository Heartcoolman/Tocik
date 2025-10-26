//
//  Note.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 增强版
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var content: String // Markdown格式内容
    var category: String
    var tagsData: String // 标签列表（逗号分隔）
    var createdDate: Date
    var modifiedDate: Date
    var isPinned: Bool
    var relatedCourseId: UUID? // 关联课程ID（可选）
    var subjectId: UUID? // v5.0: 关联科目ID
    
    // v4.0 新增字段
    @Relationship(deleteRule: .cascade) var versions: [NoteVersion] // 版本历史
    var linkedNoteIds: String // 双向链接的笔记ID，逗号分隔
    var templateId: UUID? // 使用的模板ID
    @Attribute(.externalStorage) var attachmentData: Data? // OCR图片附件
    var mindMapData: String // 思维导图数据（JSON格式）
    var wordCount: Int // 字数统计
    var isFavorite: Bool // 收藏
    
    // 计算属性：转换字符串为数组
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    var linkedNotes: [UUID] {
        get {
            linkedNoteIds.isEmpty ? [] : linkedNoteIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            linkedNoteIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    init(title: String, content: String = "", category: String = "通用", tags: [String] = [], isPinned: Bool = false, relatedCourseId: UUID? = nil, templateId: UUID? = nil, subjectId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.tagsData = tags.joined(separator: ",")
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.isPinned = isPinned
        self.relatedCourseId = relatedCourseId
        self.subjectId = subjectId // v5.0
        
        // v4.0 初始化
        self.versions = []
        self.linkedNoteIds = ""
        self.templateId = templateId
        self.attachmentData = nil
        self.mindMapData = ""
        self.wordCount = content.count
        self.isFavorite = false
    }
    
    // 更新笔记内容并保存版本
    func updateContent(_ newContent: String, changeDescription: String = "编辑") {
        // 如果内容有变化，保存当前版本
        if content != newContent {
            let version = NoteVersion(content: content, changeDescription: changeDescription)
            versions.append(version)
        }
        
        content = newContent
        modifiedDate = Date()
        wordCount = newContent.count
        
        // 只保留最近20个版本
        if versions.count > 20 {
            versions = Array(versions.suffix(20))
        }
    }
    
    // 恢复到指定版本
    func restoreVersion(_ version: NoteVersion) {
        updateContent(version.content, changeDescription: "恢复到 \(version.createdDate.formatted())")
    }
    
    // 提取笔记大纲（基于Markdown标题）
    func extractOutline() -> [String] {
        let lines = content.split(separator: "\n")
        return lines.filter { $0.hasPrefix("#") }.map { String($0) }
    }
}

