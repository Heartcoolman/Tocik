//
//  SubTask.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 子任务系统
//

import Foundation
import SwiftData

@Model
final class SubTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var orderIndex: Int
    var createdDate: Date
    var completedDate: Date?
    
    init(title: String, orderIndex: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.orderIndex = orderIndex
        self.createdDate = Date()
        self.completedDate = nil
    }
}

