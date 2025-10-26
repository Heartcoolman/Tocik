//
//  CourseItem.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 增强版
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class CourseItem {
    var id: UUID
    var courseName: String
    var location: String
    var teacher: String
    var weekday: Int // 1-7 (周一到周日)
    var startTime: Date // 使用Date存储时间
    var endTime: Date
    var colorHex: String
    var notifyMinutesBefore: Int
    
    // v4.0 新增字段
    var previewReminderEnabled: Bool // 预习提醒开关
    var previewReminderTime: Int // 提前N小时提醒预习
    @Relationship(deleteRule: .cascade) var materials: [Attachment] // 课程资料
    @Relationship(deleteRule: .cascade) var attendanceRecords: [AttendanceRecord] // 出勤记录
    var courseRating: Double // 课程评分 (0-5)
    var difficultyLevel: DifficultyLevel
    var studyGroupId: UUID? // 关联的学习小组
    var courseDescription: String // 课程描述
    var credits: Double // 学分
    
    enum DifficultyLevel: Int, Codable {
        case easy = 1
        case medium = 2
        case hard = 3
        case veryHard = 4
        
        var displayName: String {
            switch self {
            case .easy: return "简单"
            case .medium: return "中等"
            case .hard: return "困难"
            case .veryHard: return "很难"
            }
        }
        
        var emoji: String {
            switch self {
            case .easy: return "😊"
            case .medium: return "😐"
            case .hard: return "😰"
            case .veryHard: return "🔥"
            }
        }
    }
    
    init(courseName: String, location: String = "", teacher: String = "", weekday: Int, startTime: Date, endTime: Date, colorHex: String = "#4A90E2", notifyMinutesBefore: Int = 10) {
        self.id = UUID()
        self.courseName = courseName
        self.location = location
        self.teacher = teacher
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.colorHex = colorHex
        self.notifyMinutesBefore = notifyMinutesBefore
        
        // v4.0 初始化
        self.previewReminderEnabled = false
        self.previewReminderTime = 24 // 提前24小时
        self.materials = []
        self.attendanceRecords = []
        self.courseRating = 0
        self.difficultyLevel = .medium
        self.studyGroupId = nil
        self.courseDescription = ""
        self.credits = 0
    }
    
    // 出勤率
    func attendanceRate() -> Double {
        guard !attendanceRecords.isEmpty else { return 0 }
        let attended = attendanceRecords.filter { $0.didAttend }.count
        return Double(attended) / Double(attendanceRecords.count)
    }
}

// 出勤记录
@Model
final class AttendanceRecord {
    var id: UUID
    var date: Date
    var didAttend: Bool
    var note: String
    
    init(date: Date, didAttend: Bool = true, note: String = "") {
        self.id = UUID()
        self.date = date
        self.didAttend = didAttend
        self.note = note
    }
}

