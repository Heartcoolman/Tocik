//
//  CalendarView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [CalendarEvent]
    
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月份选择器
                MonthSelector(currentMonth: $currentMonth)
                    .padding()
                
                // 日历网格
                CalendarGrid(
                    currentMonth: currentMonth,
                    selectedDate: $selectedDate,
                    events: events
                )
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 8)
                
                // 事件列表
                if let selectedDate = selectedDate {
                    EventList(date: selectedDate, events: eventsForDate(selectedDate))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("选择日期查看事件")
                            .font(Theme.bodyFont)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("日历")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.calendarColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(selectedDate: selectedDate ?? Date())
            }
        }
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }
}

struct MonthSelector: View {
    @Binding var currentMonth: Date
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Theme.calendarColor)
            }
            
            Spacer()
            
            Text(monthYearString())
                .font(Theme.headlineFont)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.calendarColor)
            }
        }
    }
    
    private func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: currentMonth)
    }
    
    private func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct CalendarGrid: View {
    let currentMonth: Date
    @Binding var selectedDate: Date?
    let events: [CalendarEvent]
    
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // 星期标题
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日期网格
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!),
                            isToday: date.isToday,
                            hasEvents: hasEvents(on: date),
                            isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while days.count < 42 { // 6周 x 7天
            days.append(date)
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return days
    }
    
    private func hasEvents(on date: Date) -> Bool {
        events.contains { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date)
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let isCurrentMonth: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 17, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundColor(textColor())
            
            if hasEvents {
                Circle()
                    .fill(
                        isSelected ?
                        LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                        Theme.calendarGradient
                    )
                    .frame(width: 6, height: 6)
                    .shadow(color: Theme.calendarColor.opacity(0.5), radius: 4, y: 2)
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if isSelected {
                    Theme.calendarGradient
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if isToday {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.calendarColor.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.calendarGradient, lineWidth: 2)
                        )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: isSelected ? Theme.calendarColor.opacity(0.3) : .clear, radius: 8, y: 4)
    }
    
    private func textColor() -> Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.5)
        }
        if isSelected {
            return .white
        }
        if isToday {
            return Theme.calendarColor
        }
        return .primary
    }
}

struct EventList: View {
    let date: Date
    let events: [CalendarEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date.formatted("MM月dd日"))
                .font(Theme.headlineFont)
                .padding(.horizontal)
            
            if events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("暂无事件")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            EventRow(event: event)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct EventRow: View {
    let event: CalendarEvent
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var eventGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: event.colorHex), Color(hex: event.colorHex).opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 彩色渐变条
            RoundedRectangle(cornerRadius: 4)
                .fill(eventGradient)
                .frame(width: 6)
            
            HStack(spacing: Theme.spacing.medium) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 17, weight: .semibold))
                    
                    if !event.eventDescription.isEmpty {
                        Text(event.eventDescription)
                            .font(Theme.captionFont)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if !event.isAllDay {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(timeRange(from: event.startDate, to: event.endDate))
                                .font(.caption2)
                        }
                        .foregroundStyle(eventGradient)
                    }
                }
                
                Spacer()
            }
            .padding(.leading, Theme.spacing.medium)
            .padding(.vertical, Theme.spacing.medium)
        }
        .background(
            ZStack {
                if colorScheme == .dark {
                    Color(.systemGray6)
                } else {
                    Color.white
                }
                
                // 渐变叠加
                eventGradient.opacity(0.05)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.06), radius: 10, x: 0, y: 5)
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(event)
                try? modelContext.save()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
    
    private func timeRange(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}


