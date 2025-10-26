//
//  RecurrenceRule.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 重复任务规则
//

import Foundation
import SwiftData

@Model
final class RecurrenceRule {
    var id: UUID
    var frequency: Frequency
    var interval: Int // 间隔数（如每2天、每3周）
    var daysOfWeekData: String // 一周中的哪几天（用于每周重复），逗号分隔 "1,3,5"
    var endType: EndType
    var endDate: Date?
    var occurrenceCount: Int? // 重复次数
    var createdDate: Date
    
    enum Frequency: String, Codable {
        case daily = "每天"
        case weekly = "每周"
        case monthly = "每月"
        case yearly = "每年"
    }
    
    enum EndType: String, Codable {
        case never = "永不结束"
        case afterCount = "重复次数后"
        case onDate = "在日期"
    }
    
    var daysOfWeek: [Int] {
        get {
            daysOfWeekData.isEmpty ? [] : daysOfWeekData.split(separator: ",").compactMap { Int($0) }
        }
        set {
            daysOfWeekData = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    init(frequency: Frequency = .daily, interval: Int = 1, daysOfWeek: [Int] = [], endType: EndType = .never) {
        self.id = UUID()
        self.frequency = frequency
        self.interval = interval
        self.daysOfWeekData = daysOfWeek.map { String($0) }.joined(separator: ",")
        self.endType = endType
        self.endDate = nil
        self.occurrenceCount = nil
        self.createdDate = Date()
    }
    
    // 计算下一次出现的日期
    func nextOccurrence(after date: Date) -> Date? {
        let calendar = Calendar.current
        
        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: interval, to: date)
        case .weekly:
            if daysOfWeek.isEmpty {
                return calendar.date(byAdding: .weekOfYear, value: interval, to: date)
            } else {
                // 找到下一个匹配的星期几
                var nextDate = date
                for _ in 0..<7 {
                    nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
                    let weekday = calendar.component(.weekday, from: nextDate)
                    if daysOfWeek.contains(weekday) {
                        return nextDate
                    }
                }
            }
        case .monthly:
            return calendar.date(byAdding: .month, value: interval, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: interval, to: date)
        }
        
        return nil
    }
}

