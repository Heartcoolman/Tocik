//
//  TaskComment.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 任务评论系统
//

import Foundation
import SwiftData

@Model
final class TaskComment {
    var id: UUID
    var content: String
    var createdDate: Date
    var modifiedDate: Date
    @Attribute(.externalStorage) var attachmentData: Data? // 可选的图片或文件
    var attachmentType: AttachmentType?
    
    enum AttachmentType: String, Codable {
        case image = "图片"
        case audio = "语音"
        case file = "文件"
    }
    
    init(content: String, attachmentData: Data? = nil, attachmentType: AttachmentType? = nil) {
        self.id = UUID()
        self.content = content
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.attachmentData = attachmentData
        self.attachmentType = attachmentType
    }
}

