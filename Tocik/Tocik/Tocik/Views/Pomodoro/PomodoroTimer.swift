//
//  PomodoroTimer.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import Combine

@MainActor
class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: Int = 25 * 60 // 秒
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .work
    @Published var sessionsCompleted = 0
    
    private var timer: Timer?
    private let notificationManager = NotificationManager.shared
    
    enum TimerMode {
        case work
        case shortBreak
        case longBreak
        
        var duration: Int {
            switch self {
            case .work: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
        
        var title: String {
            switch self {
            case .work: return "工作时间"
            case .shortBreak: return "短休息"
            case .longBreak: return "长休息"
            }
        }
        
        var emoji: String {
            switch self {
            case .work: return "💪"
            case .shortBreak: return "☕️"
            case .longBreak: return "🎉"
            }
        }
    }
    
    init() {
        timeRemaining = currentMode.duration
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = currentMode.duration
    }
    
    func skip() {
        pause()
        completeSession()
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeSession()
        }
    }
    
    private func completeSession() {
        pause()
        
        // 发送通知
        Task {
            if await notificationManager.requestAuthorization() {
                let nextMode = getNextMode()
                notificationManager.schedulePomodoroNotification(
                    title: "\(currentMode.title)完成！",
                    body: "是时候\(nextMode.title)了 \(nextMode.emoji)",
                    after: 1
                )
            }
        }
        
        // 如果是工作时段完成，增加计数
        if currentMode == .work {
            sessionsCompleted += 1
        }
        
        // 切换到下一个模式
        switchToNextMode()
    }
    
    private func getNextMode() -> TimerMode {
        switch currentMode {
        case .work:
            // 每4个番茄钟后进行长休息
            return (sessionsCompleted + 1) % 4 == 0 ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            return .work
        }
    }
    
    private func switchToNextMode() {
        currentMode = getNextMode()
        timeRemaining = currentMode.duration
    }
    
    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        let total = Double(currentMode.duration)
        let remaining = Double(timeRemaining)
        return (total - remaining) / total
    }
}

