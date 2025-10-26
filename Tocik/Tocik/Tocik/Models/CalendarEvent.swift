//
//  CalendarEvent.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var id: UUID
    var title: String
    var eventDescription: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var reminderMinutes: Int? // nil表示无提醒
    var colorHex: String
    
    init(title: String, eventDescription: String = "", startDate: Date, endDate: Date, isAllDay: Bool = false, reminderMinutes: Int? = nil, colorHex: String = "#FF6B6B") {
        self.id = UUID()
        self.title = title
        self.eventDescription = eventDescription
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.reminderMinutes = reminderMinutes
        self.colorHex = colorHex
    }
}

