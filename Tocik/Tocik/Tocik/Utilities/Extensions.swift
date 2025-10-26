//
//  Extensions.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    // 获取日期的开始时间（00:00:00）
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    // 获取日期的结束时间（23:59:59）
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // 判断是否是今天
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    // 判断是否是本周
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    // 格式化日期
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    // 友好的时间显示
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)年前"
        }
        if let month = components.month, month > 0 {
            return "\(month)个月前"
        }
        if let day = components.day, day > 0 {
            return "\(day)天前"
        }
        if let hour = components.hour, hour > 0 {
            return "\(hour)小时前"
        }
        if let minute = components.minute, minute > 0 {
            return "\(minute)分钟前"
        }
        return "刚刚"
    }
    
    // 获取星期几（1-7，周一到周日）
    var weekday: Int {
        let weekday = Calendar.current.component(.weekday, from: self)
        // 将周日(1)转换为7，周一(2)转换为1，以此类推
        return weekday == 1 ? 7 : weekday - 1
    }
}

// MARK: - String Extensions
extension String {
    // 去除首尾空格和换行
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // 判断是否为空（包括只有空格的情况）
    var isBlank: Bool {
        self.trimmed.isEmpty
    }
}

// MARK: - View Extensions
extension View {
    // 卡片样式
    func cardStyle(colorScheme: ColorScheme = .light) -> some View {
        self
            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    // 条件修饰符
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Int Extensions
extension Int {
    // 将分钟转换为时分格式
    func minutesToHoursMinutes() -> (hours: Int, minutes: Int) {
        return (self / 60, self % 60)
    }
}

// MARK: - Double Extensions  
extension Double {
    // 格式化为小数点后n位
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

