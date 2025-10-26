//
//  NoteVersion.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 笔记版本历史
//

import Foundation
import SwiftData

@Model
final class NoteVersion {
    var id: UUID
    var content: String
    var createdDate: Date
    var changeDescription: String // 修改说明
    
    init(content: String, changeDescription: String = "自动保存") {
        self.id = UUID()
        self.content = content
        self.createdDate = Date()
        self.changeDescription = changeDescription
    }
}

