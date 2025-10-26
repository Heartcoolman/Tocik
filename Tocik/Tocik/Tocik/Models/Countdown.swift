//
//  Countdown.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class Countdown {
    var id: UUID
    var title: String
    var targetDate: Date
    var eventDescription: String
    var colorHex: String
    var icon: String
    var isImportant: Bool
    var createdDate: Date
    
    init(title: String, targetDate: Date, eventDescription: String = "", colorHex: String = "#FF6B6B", icon: String = "calendar", isImportant: Bool = false) {
        self.id = UUID()
        self.title = title
        self.targetDate = targetDate
        self.eventDescription = eventDescription
        self.colorHex = colorHex
        self.icon = icon
        self.isImportant = isImportant
        self.createdDate = Date()
    }
    
    // 计算剩余天数
    func daysRemaining() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return components.day ?? 0
    }
    
    // 计算进度百分比（如果有起始日期的话）
    func progressPercentage(from startDate: Date? = nil) -> Double {
        guard let start = startDate else { return 0 }
        let total = targetDate.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return min(max(elapsed / total * 100, 0), 100)
    }
}

