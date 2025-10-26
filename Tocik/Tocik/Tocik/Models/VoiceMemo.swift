//
//  VoiceMemo.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class VoiceMemo {
    var id: UUID
    var title: String
    var audioFileName: String // 音频文件名
    var transcription: String // 转录文本
    var duration: TimeInterval
    var tagsData: String // 标签（逗号分隔）
    var createdDate: Date
    var isTranscribed: Bool
    
    // 计算属性
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    init(title: String, audioFileName: String, duration: TimeInterval = 0, transcription: String = "") {
        self.id = UUID()
        self.title = title
        self.audioFileName = audioFileName
        self.transcription = transcription
        self.duration = duration
        self.tagsData = ""
        self.createdDate = Date()
        self.isTranscribed = !transcription.isEmpty
    }
    
    func formattedDuration() -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

