//
//  Attachment.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 通用附件系统
//

import Foundation
import SwiftData

@Model
final class Attachment {
    var id: UUID
    var fileName: String
    var fileType: FileType
    @Attribute(.externalStorage) var fileData: Data
    var fileSize: Int64
    var createdDate: Date
    var thumbnailData: Data? // 缩略图（用于图片）
    
    enum FileType: String, Codable {
        case image = "图片"
        case audio = "音频"
        case video = "视频"
        case document = "文档"
        case other = "其他"
        
        var iconName: String {
            switch self {
            case .image: return "photo"
            case .audio: return "waveform"
            case .video: return "video"
            case .document: return "doc"
            case .other: return "paperclip"
            }
        }
    }
    
    init(fileName: String, fileType: FileType, fileData: Data) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.fileData = fileData
        self.fileSize = Int64(fileData.count)
        self.createdDate = Date()
        self.thumbnailData = nil
    }
    
    // 格式化文件大小
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

