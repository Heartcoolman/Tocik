//
//  LinkReference.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 笔记双向链接
//

import Foundation
import SwiftData

@Model
final class LinkReference {
    var id: UUID
    var sourceNoteId: UUID // 源笔记
    var targetNoteId: UUID // 目标笔记
    var linkText: String // 链接显示的文本
    var createdDate: Date
    
    init(sourceNoteId: UUID, targetNoteId: UUID, linkText: String) {
        self.id = UUID()
        self.sourceNoteId = sourceNoteId
        self.targetNoteId = targetNoteId
        self.linkText = linkText
        self.createdDate = Date()
    }
}

