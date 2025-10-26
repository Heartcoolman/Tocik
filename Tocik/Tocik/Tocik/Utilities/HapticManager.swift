//
//  HapticManager.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 触觉反馈管理
//

import Foundation
import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // 成功反馈
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // 警告反馈
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // 错误反馈
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // 轻微反馈
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // 中等反馈
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // 重量反馈
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // 选择反馈
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // 自定义模式反馈
    func pattern(_ pattern: HapticPattern) {
        switch pattern {
        case .complete:
            // 完成任务：轻-重
            light()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.medium()
            }
        case .delete:
            // 删除：中-中
            medium()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.medium()
            }
        case .unlock:
            // 解锁成就：轻-中-重
            light()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.medium()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.heavy()
            }
        case .timer:
            // 计时器结束：重-重-重
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    self.heavy()
                }
            }
        }
    }
    
    enum HapticPattern {
        case complete   // 完成任务
        case delete     // 删除
        case unlock     // 解锁成就
        case timer      // 计时器结束
    }
}

