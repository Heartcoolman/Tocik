//
//  PomodoroSettings.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class PomodoroSettings {
    var id: UUID
    var workDuration: Int // 分钟
    var shortBreakDuration: Int // 分钟
    var longBreakDuration: Int // 分钟
    var selectedSound: String // SoundType rawValue
    var soundVolume: Float
    var autoStartBreak: Bool
    var autoStartWork: Bool
    var sessionsBeforeLongBreak: Int
    
    init(
        workDuration: Int = 25,
        shortBreakDuration: Int = 5,
        longBreakDuration: Int = 15,
        selectedSound: String = "bell",
        soundVolume: Float = 0.7,
        autoStartBreak: Bool = false,
        autoStartWork: Bool = false,
        sessionsBeforeLongBreak: Int = 4
    ) {
        self.id = UUID()
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.selectedSound = selectedSound
        self.soundVolume = soundVolume
        self.autoStartBreak = autoStartBreak
        self.autoStartWork = autoStartWork
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
    }
}

