//
//  PomodoroTodoLink.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class PomodoroTodoLink {
    var id: UUID
    var todoId: UUID
    var pomodoroSessionId: UUID
    var createdDate: Date
    
    init(todoId: UUID, pomodoroSessionId: UUID) {
        self.id = UUID()
        self.todoId = todoId
        self.pomodoroSessionId = pomodoroSessionId
        self.createdDate = Date()
    }
}

