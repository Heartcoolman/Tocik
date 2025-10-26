//
//  TimelineEntry.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class TimelineEntry {
    var id: UUID
    var date: Date
    var entryType: EntryType
    var title: String
    var content: String
    var relatedId: UUID? // 关联的其他数据ID
    var imageData: Data? // 可选图片
    var mood: Mood?
    
    enum EntryType: String, Codable {
        case auto = "自动"
        case manual = "手动"
        case pomodoro = "番茄钟"
        case todo = "待办"
        case course = "课程"
        case event = "事件"
        
        var icon: String {
            switch self {
            case .auto: return "sparkles"
            case .manual: return "pencil"
            case .pomodoro: return "timer"
            case .todo: return "checklist"
            case .course: return "book"
            case .event: return "calendar"
            }
        }
    }
    
    enum Mood: String, Codable, CaseIterable {
        case veryHappy = "😄"
        case happy = "😊"
        case neutral = "😐"
        case sad = "😔"
        case stressed = "😰"
        
        var displayName: String { rawValue }
    }
    
    init(date: Date = Date(), entryType: EntryType, title: String, content: String = "", relatedId: UUID? = nil, mood: Mood? = nil) {
        self.id = UUID()
        self.date = date
        self.entryType = entryType
        self.title = title
        self.content = content
        self.relatedId = relatedId
        self.imageData = nil
        self.mood = mood
    }
}

