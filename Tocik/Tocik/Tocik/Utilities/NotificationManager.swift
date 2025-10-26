//
//  NotificationManager.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        Task {
            await checkAuthorization()
        }
    }
    
    // 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("通知权限请求失败: \(error)")
            return false
        }
    }
    
    // 检查当前授权状态
    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - 番茄钟通知
    func schedulePomodoroNotification(title: String, body: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "POMODORO"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加番茄钟通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 课程通知
    func scheduleCourseNotification(courseId: UUID, courseName: String, location: String, startTime: Date, minutesBefore: Int) {
        let content = UNMutableNotificationContent()
        content.title = "即将上课"
        content.body = "\(courseName) - \(location)"
        content.sound = .default
        content.categoryIdentifier = "COURSE"
        content.userInfo = ["courseId": courseId.uuidString]
        
        let notificationDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: startTime)!
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: notificationDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "course-\(courseId.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加课程通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 日历事件通知
    func scheduleEventNotification(eventId: UUID, title: String, date: Date, minutesBefore: Int) {
        let content = UNMutableNotificationContent()
        content.title = "事件提醒"
        content.body = title
        content.sound = .default
        content.categoryIdentifier = "EVENT"
        content.userInfo = ["eventId": eventId.uuidString]
        
        let notificationDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: date)!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "event-\(eventId.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加事件通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 待办事项通知
    func scheduleTodoNotification(todoId: UUID, title: String, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "待办提醒"
        content.body = title
        content.sound = .default
        content.categoryIdentifier = "TODO"
        content.userInfo = ["todoId": todoId.uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "todo-\(todoId.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加待办通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 习惯提醒通知
    func scheduleHabitNotification(habitId: UUID, habitName: String, at time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "习惯提醒"
        content.body = "该完成今天的「\(habitName)」了"
        content.sound = .default
        content.categoryIdentifier = "HABIT"
        content.userInfo = ["habitId": habitId.uuidString]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "habit-\(habitId.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加习惯通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 移除通知
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 移除特定类型的通知
    func removeCourseNotifications(courseId: UUID) {
        removeNotification(withIdentifier: "course-\(courseId.uuidString)")
    }
    
    func removeEventNotifications(eventId: UUID) {
        removeNotification(withIdentifier: "event-\(eventId.uuidString)")
    }
    
    func removeTodoNotifications(todoId: UUID) {
        removeNotification(withIdentifier: "todo-\(todoId.uuidString)")
    }
    
    func removeHabitNotifications(habitId: UUID) {
        removeNotification(withIdentifier: "habit-\(habitId.uuidString)")
    }
}

