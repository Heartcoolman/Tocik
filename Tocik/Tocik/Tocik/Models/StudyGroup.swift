//
//  StudyGroup.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 学习小组（基础版）
//

import Foundation
import SwiftData

@Model
final class StudyGroup {
    var id: UUID
    var name: String
    var groupDescription: String
    var createdDate: Date
    var memberCount: Int
    var sharedCourseIds: String // 共享的课程ID，逗号分隔
    var sharedNoteIds: String // 共享的笔记ID，逗号分隔
    var colorHex: String
    var inviteCode: String // 邀请码
    
    init(name: String, groupDescription: String = "", colorHex: String = "#4A90E2") {
        self.id = UUID()
        self.name = name
        self.groupDescription = groupDescription
        self.createdDate = Date()
        self.memberCount = 1
        self.sharedCourseIds = ""
        self.sharedNoteIds = ""
        self.colorHex = colorHex
        self.inviteCode = String(format: "%06d", Int.random(in: 100000...999999))
    }
    
    var sharedCourses: [UUID] {
        get {
            sharedCourseIds.isEmpty ? [] : sharedCourseIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            sharedCourseIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
    
    var sharedNotes: [UUID] {
        get {
            sharedNoteIds.isEmpty ? [] : sharedNoteIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        }
        set {
            sharedNoteIds = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
}

