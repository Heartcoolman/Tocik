//
//  QRRecord.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class QRRecord {
    var id: UUID
    var content: String
    var recordType: RecordType
    var qrType: QRType
    var createdDate: Date
    var isFavorite: Bool
    
    enum RecordType: String, Codable {
        case scanned = "扫描"
        case generated = "生成"
    }
    
    enum QRType: String, Codable {
        case text = "文本"
        case url = "链接"
        case wifi = "WiFi"
        case contact = "联系人"
        case other = "其他"
        
        var icon: String {
            switch self {
            case .text: return "text.alignleft"
            case .url: return "link"
            case .wifi: return "wifi"
            case .contact: return "person.crop.circle"
            case .other: return "qrcode"
            }
        }
    }
    
    init(content: String, recordType: RecordType, qrType: QRType = .text) {
        self.id = UUID()
        self.content = content
        self.recordType = recordType
        self.qrType = qrType
        self.createdDate = Date()
        self.isFavorite = false
    }
}

