//
//  KnowledgeNode.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  知识图谱节点模型
//

import Foundation
import SwiftData

@Model
final class KnowledgeNode {
    var id: UUID
    var title: String
    var subject: String
    var nodeType: NodeType
    var nodeDescription: String
    var masteryLevel: Int // 0-100掌握度
    var prerequisiteIds: String // 前置知识点ID，逗号分隔
    var relatedNoteIds: String // 关联笔记ID
    var relatedFlashCardIds: String // 关联闪卡ID
    var createdDate: Date
    
    enum NodeType: String, Codable {
        case concept = "概念"
        case theorem = "定理"
        case formula = "公式"
        case skill = "技巧"
        case topic = "主题"
    }
    
    init(
        title: String,
        subject: String,
        nodeType: NodeType = .concept,
        description: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.subject = subject
        self.nodeType = nodeType
        self.nodeDescription = description
        self.masteryLevel = 0
        self.prerequisiteIds = ""
        self.relatedNoteIds = ""
        self.relatedFlashCardIds = ""
        self.createdDate = Date()
    }
    
    // 前置知识点数组
    var prerequisites: [UUID] {
        get {
            prerequisiteIds.isEmpty ? [] : prerequisiteIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            prerequisiteIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    // 关联笔记数组
    var relatedNotes: [UUID] {
        get {
            relatedNoteIds.isEmpty ? [] : relatedNoteIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            relatedNoteIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
}

