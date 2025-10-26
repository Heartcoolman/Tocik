//
//  PerformanceOptimizer.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 性能优化工具
//

import Foundation
import UIKit

class PerformanceOptimizer {
    // 图片压缩
    static func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        let maxBytes = maxSizeKB * 1024
        
        while let data = imageData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    // 生成缩略图
    static func generateThumbnail(_ image: UIImage, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
    
    // 批量处理（分页）
    static func processBatch<T>(
        items: [T],
        batchSize: Int = 50,
        processor: (ArraySlice<T>) -> Void
    ) {
        let batches = stride(from: 0, to: items.count, by: batchSize).map { startIndex in
            let endIndex = min(startIndex + batchSize, items.count)
            return items[startIndex..<endIndex]
        }
        
        for batch in batches {
            processor(batch)
        }
    }
    
    // 缓存管理
    static let imageCache = NSCache<NSString, UIImage>()
    
    static func cachedImage(forKey key: String, generator: () -> UIImage?) -> UIImage? {
        if let cached = imageCache.object(forKey: key as NSString) {
            return cached
        }
        
        if let image = generator() {
            imageCache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    // 清理缓存
    static func clearCache() {
        imageCache.removeAllObjects()
    }
    
    // 延迟加载
    static func delayedLoad<T>(
        delay: TimeInterval = 0.1,
        action: @escaping () -> T
    ) async -> T {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return action()
    }
}

// MARK: - 数据清理建议

struct DataCleanupSuggestion {
    let type: CleanupType
    let itemCount: Int
    let estimatedSpace: Int64 // 字节
    let description: String
    
    enum CleanupType {
        case oldCompletedTodos
        case oldNoteVersions
        case unusedAttachments
        case oldPomodoroSessions
        case archivedGoals
    }
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: estimatedSpace, countStyle: .file)
    }
}

class DataCleanupAnalyzer {
    // 分析可清理的数据
    static func analyzecleanupOpportunities(
        todos: [TodoItem],
        notes: [Note],
        attachments: [Attachment],
        pomodoroSessions: [PomodoroSession],
        goals: [Goal]
    ) -> [DataCleanupSuggestion] {
        var suggestions: [DataCleanupSuggestion] = []
        
        // 检查旧的已完成待办
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())!
        let oldTodos = todos.filter {
            $0.isCompleted && ($0.completedDate ?? Date.distantPast) < threeMonthsAgo
        }
        if oldTodos.count >= 10 {
            suggestions.append(DataCleanupSuggestion(
                type: .oldCompletedTodos,
                itemCount: oldTodos.count,
                estimatedSpace: Int64(oldTodos.count * 500),
                description: "3个月前完成的待办任务"
            ))
        }
        
        // 检查笔记版本
        var totalVersions = 0
        for note in notes {
            totalVersions += note.versions.count
        }
        if totalVersions >= 100 {
            suggestions.append(DataCleanupSuggestion(
                type: .oldNoteVersions,
                itemCount: totalVersions,
                estimatedSpace: Int64(totalVersions * 1000),
                description: "笔记历史版本"
            ))
        }
        
        // 检查旧番茄钟记录
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date())!
        let oldSessions = pomodoroSessions.filter { $0.startTime < sixMonthsAgo }
        if oldSessions.count >= 100 {
            suggestions.append(DataCleanupSuggestion(
                type: .oldPomodoroSessions,
                itemCount: oldSessions.count,
                estimatedSpace: Int64(oldSessions.count * 200),
                description: "6个月前的番茄钟记录"
            ))
        }
        
        // 检查已归档目标
        let archivedGoals = goals.filter { $0.isArchived }
        if archivedGoals.count >= 5 {
            suggestions.append(DataCleanupSuggestion(
                type: .archivedGoals,
                itemCount: archivedGoals.count,
                estimatedSpace: Int64(archivedGoals.count * 1000),
                description: "已归档的目标"
            ))
        }
        
        return suggestions
    }
}

