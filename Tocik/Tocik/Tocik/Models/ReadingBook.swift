//
//  ReadingBook.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class ReadingBook {
    var id: UUID
    var fileName: String
    var content: String
    var currentPosition: Int // 当前阅读位置（字符索引）
    var bookmarksData: String // 书签位置列表（逗号分隔的字符串）
    var lastReadDate: Date
    var source: BookSource
    var webdavPath: String? // WebDAV路径（如果来自云端）
    
    // 计算属性：转换字符串为数组
    var bookmarks: [Int] {
        get {
            bookmarksData.split(separator: ",").compactMap { Int($0) }
        }
        set {
            bookmarksData = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    enum BookSource: String, Codable {
        case local = "本地"
        case webdav = "WebDAV"
    }
    
    init(fileName: String, content: String, currentPosition: Int = 0, bookmarks: [Int] = [], source: BookSource = .local, webdavPath: String? = nil) {
        self.id = UUID()
        self.fileName = fileName
        self.content = content
        self.currentPosition = currentPosition
        self.bookmarksData = bookmarks.map { String($0) }.joined(separator: ",")
        self.lastReadDate = Date()
        self.source = source
        self.webdavPath = webdavPath
    }
}

