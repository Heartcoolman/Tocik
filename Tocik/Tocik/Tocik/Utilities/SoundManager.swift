//
//  SoundManager.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import AVFoundation
import UIKit
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    @Published var volume: Float = 0.7
    
    enum SoundType: String, CaseIterable {
        case bell = "铃铛"
        case chime = "钟声"
        case gong = "锣声"
        case digital = "数字音"
        case soft = "柔和音"
        case custom = "自定义"
        
        var systemSound: SystemSoundID? {
            switch self {
            case .bell: return 1013 // UILocalNotificationDefaultSoundName
            case .chime: return 1013
            case .gong: return 1013
            case .digital: return 1013
            case .soft: return 1013
            case .custom: return nil
            }
        }
        
        var fileName: String? {
            switch self {
            case .bell: return "bell"
            case .chime: return "chime"
            case .gong: return "gong"
            case .digital: return "digital"
            case .soft: return "soft"
            case .custom: return nil
            }
        }
    }
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
    
    // 播放系统音效
    func playSystemSound(_ type: SoundType) {
        // 使用系统默认提示音
        AudioServicesPlaySystemSound(1013)
        
        // 触觉反馈
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    // 播放自定义音频文件
    func playCustomSound(fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("播放自定义音频失败: \(error)")
        }
    }
    
    // 播放内置音效（使用beep作为占位）
    func playSound(_ type: SoundType, volume: Float? = nil) {
        let _ = volume ?? self.volume
        
        // 简单实现：使用系统音效
        if let systemSound = type.systemSound {
            AudioServicesPlaySystemSound(systemSound)
        }
        
        // 触觉反馈
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    // 预览音效
    func previewSound(_ type: SoundType, volume: Float) {
        playSound(type, volume: volume)
    }
    
    // 停止播放
    func stopSound() {
        audioPlayer?.stop()
    }
    
    // 获取自定义音频文件路径
    func getCustomSoundURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("CustomSounds")
    }
    
    // 保存自定义音频
    func saveCustomSound(from sourceURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let destinationURL = getCustomSoundURL().appendingPathComponent(sourceURL.lastPathComponent)
        
        do {
            // 创建目录
            try FileManager.default.createDirectory(at: getCustomSoundURL(), withIntermediateDirectories: true)
            
            // 复制文件
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            completion(.success(destinationURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    // 列出所有自定义音频
    func listCustomSounds() -> [URL] {
        do {
            let soundsDirectory = getCustomSoundURL()
            let files = try FileManager.default.contentsOfDirectory(at: soundsDirectory, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "mp3" || $0.pathExtension == "m4a" || $0.pathExtension == "wav" }
        } catch {
            return []
        }
    }
}

