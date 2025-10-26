//
//  Inspiration.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class Inspiration {
    var id: UUID
    var title: String
    var content: String
    var inspirationType: InspirationType
    var tagsData: String // 标签（逗号分隔）
    var status: Status
    @Attribute(.externalStorage) var imageData: Data?
    var linkedUrl: String?
    var createdDate: Date
    var updatedDate: Date
    
    // 计算属性
    var tags: [String] {
        get {
            tagsData.isEmpty ? [] : tagsData.split(separator: ",").map { String($0) }
        }
        set {
            tagsData = newValue.joined(separator: ",")
        }
    }
    
    enum InspirationType: String, Codable, CaseIterable {
        case idea = "想法"
        case quote = "语录"
        case article = "文章"
        case image = "图片"
        case link = "链接"
        
        var icon: String {
            switch self {
            case .idea: return "lightbulb.fill"
            case .quote: return "quote.bubble.fill"
            case .article: return "doc.text.fill"
            case .image: return "photo.fill"
            case .link: return "link"
            }
        }
    }
    
    enum Status: String, Codable, CaseIterable {
        case pending = "待处理"
        case implemented = "已实现"
        case archived = "已归档"
        
        var colorHex: String {
            switch self {
            case .pending: return "#FFD93D"
            case .implemented: return "#4ECDC4"
            case .archived: return "#95A5A6"
            }
        }
    }
    
    init(title: String, content: String, inspirationType: InspirationType = .idea, linkedUrl: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.inspirationType = inspirationType
        self.tagsData = ""
        self.status = .pending
        self.imageData = nil
        self.linkedUrl = linkedUrl
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

