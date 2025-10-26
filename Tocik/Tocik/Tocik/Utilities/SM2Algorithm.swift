//
//  SM2Algorithm.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  SM-2间隔重复算法实现

import Foundation

struct SM2Algorithm {
    // SM-2算法：根据回答质量计算下次复习时间
    // quality: 0-5 (0=完全不记得, 5=完美记忆)
    static func calculateNextReview(
        card: FlashCard,
        quality: Int
    ) -> (interval: Int, easeFactor: Double, nextReviewDate: Date) {
        var newEaseFactor = card.easeFactor
        var newInterval = card.interval
        
        // 更新难易度因子
        newEaseFactor = card.easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        
        // 难易度不能低于1.3
        if newEaseFactor < 1.3 {
            newEaseFactor = 1.3
        }
        
        // 计算间隔
        if quality < 3 {
            // 回答错误，重新开始
            newInterval = 1
        } else {
            if card.interval == 0 {
                newInterval = 1
            } else if card.interval == 1 {
                newInterval = 6
            } else {
                newInterval = Int(Double(card.interval) * newEaseFactor)
            }
        }
        
        // 计算下次复习日期
        let nextDate = Calendar.current.date(byAdding: .day, value: newInterval, to: Date()) ?? Date()
        
        return (newInterval, newEaseFactor, nextDate)
    }
    
    // 简化版：只有三个选项（不记得、有点记得、记得）
    static func simpleReview(card: FlashCard, remembered: Bool) -> (interval: Int, easeFactor: Double, nextReviewDate: Date) {
        let quality = remembered ? 4 : 1
        return calculateNextReview(card: card, quality: quality)
    }
}

