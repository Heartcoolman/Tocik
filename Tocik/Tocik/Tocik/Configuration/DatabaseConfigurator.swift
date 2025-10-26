//
//  DatabaseConfigurator.swift
//  Tocik
//
//  Created: 2025/10/24
//  数据库配置 - 统一管理所有模型和Schema
//

import Foundation
import SwiftData
import os

/// 数据库配置器 - 集中管理ModelContainer配置
@MainActor
class DatabaseConfigurator {
    
    /// 创建并配置 ModelContainer
    static func createContainer() -> ModelContainer {
        let schema = createSchema()
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.database.info("💾 数据库容器创建成功 - \(schema.entities.count) 个模型")
            return container
        } catch {
            AppLogger.database.error("❌ 数据库容器创建失败: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    /// 创建数据Schema
    private static func createSchema() -> Schema {
        return Schema([
            // v3.0 原有模型
            PomodoroSession.self,
            CourseItem.self,
            CalendarEvent.self,
            ReadingBook.self,
            TodoItem.self,
            Habit.self,
            HabitRecord.self,
            Countdown.self,
            Note.self,
            FlashCard.self,
            FlashDeck.self,
            Transaction.self,
            Budget.self,
            Goal.self,
            KeyResult.self,
            QRRecord.self,
            VoiceMemo.self,
            WrongQuestion.self,
            TimelineEntry.self,
            Inspiration.self,
            PomodoroTodoLink.self,
            PomodoroSettings.self,
            
            // v4.0 新增模型
            SubTask.self,
            RecurrenceRule.self,
            TaskComment.self,
            Attachment.self,
            NoteVersion.self,
            NoteTemplate.self,
            LinkReference.self,
            Achievement.self,
            UserLevel.self,
            LearningPath.self,
            LearningMilestone.self,
            StudyGroup.self,
            PersonalReport.self,
            SmartSuggestion.self,
            AttendanceRecord.self,
            
            // v4.1 混合AI系统
            UserProfile.self,
            SuggestionFeedback.self,
            RecommendedAction.self,
            
            // v4.2 学习专属工具
            Exam.self,
            Subject.self,
            ReviewPlan.self,
            ReviewSession.self,
            KnowledgeNode.self,
            StudyJournal.self,
            QASession.self
        ])
    }
}

