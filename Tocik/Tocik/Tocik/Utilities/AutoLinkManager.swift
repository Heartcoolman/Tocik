//
//  AutoLinkManager.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 自动关联管理
//

import Foundation
import SwiftData

@MainActor
class AutoLinkManager {
    // 从目标自动创建待办任务
    static func decomposeGoalToTodos(goal: Goal, context: ModelContext) -> [TodoItem] {
        var todos: [TodoItem] = []
        
        for (index, kr) in goal.keyResults.enumerated() {
            // 为每个关键结果创建待办
            let todo = TodoItem(
                title: "\(goal.title) - \(kr.title)",
                notes: "目标：\(kr.targetValue) \(kr.unit)\n当前：\(kr.currentValue) \(kr.unit)",
                priority: index == 0 ? .high : .medium,
                category: "目标任务",
                estimatedPomodoros: Int(ceil(kr.targetValue / 10))
            )
            
            context.insert(todo)
            todos.append(todo)
        }
        
        // 更新目标的关联任务
        goal.relatedTodos = todos.map { $0.id }
        
        return todos
    }
    
    // 从错题自动创建闪卡
    static func convertWrongQuestionToFlashCard(
        wrongQuestion: WrongQuestion,
        context: ModelContext,
        deck: FlashDeck?
    ) -> FlashCard {
        let card = FlashCard(
            question: "【\(wrongQuestion.subject)】\(wrongQuestion.note.isEmpty ? "错题" : wrongQuestion.note)",
            answer: wrongQuestion.analysis,
            difficulty: wrongQuestion.difficultyRating >= 4 ? .hard : wrongQuestion.difficultyRating >= 3 ? .medium : .easy
        )
        
        // 添加标签
        card.tags = [wrongQuestion.subject] + wrongQuestion.knowledgePoints.split(separator: ",").map { String($0) }
        card.explanation = wrongQuestion.analysis
        
        context.insert(card)
        
        // 如果指定了卡片组，添加到组中
        if let deck = deck {
            deck.cards.append(card)
        }
        
        return card
    }
    
    // 从灵感转化为待办
    static func convertInspirationToTodo(
        inspiration: Inspiration,
        context: ModelContext
    ) -> TodoItem {
        let todo = TodoItem(
            title: inspiration.title,
            notes: inspiration.content,
            priority: .medium,
            category: "灵感任务",
            estimatedPomodoros: 2
        )
        
        context.insert(todo)
        
        // 更新灵感状态
        inspiration.status = .implemented
        
        return todo
    }
    
    // 从笔记提取大纲创建待办
    static func extractTasksFromNote(
        note: Note,
        context: ModelContext
    ) -> [TodoItem] {
        var todos: [TodoItem] = []
        
        // 提取Markdown中的待办项 "- [ ]"
        let lines = note.content.split(separator: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- [ ]") || trimmed.hasPrefix("* [ ]") {
                let task = trimmed
                    .replacingOccurrences(of: "- [ ]", with: "")
                    .replacingOccurrences(of: "* [ ]", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                let todo = TodoItem(
                    title: task,
                    notes: "来自笔记：\(note.title)",
                    priority: .medium,
                    category: "笔记任务",
                    estimatedPomodoros: 1
                )
                
                context.insert(todo)
                todos.append(todo)
            }
        }
        
        return todos
    }
    
    // 智能关联笔记（基于内容相似度）
    static func findRelatedNotes(
        note: Note,
        allNotes: [Note],
        threshold: Double = 0.3
    ) -> [Note] {
        return allNotes.filter { otherNote in
            guard otherNote.id != note.id else { return false }
            let similarity = calculateSimilarity(note: note, other: otherNote)
            return similarity >= threshold
        }.sorted { note1, note2 in
            calculateSimilarity(note: note, other: note1) > calculateSimilarity(note: note, other: note2)
        }
    }
    
    // 计算笔记相似度（基于标签和关键词）
    private static func calculateSimilarity(note: Note, other: Note) -> Double {
        var score = 0.0
        
        // 标签重合度
        let commonTags = Set(note.tags).intersection(Set(other.tags))
        if !note.tags.isEmpty && !other.tags.isEmpty {
            score += Double(commonTags.count) / Double(max(note.tags.count, other.tags.count)) * 0.6
        }
        
        // 分类相同
        if note.category == other.category {
            score += 0.2
        }
        
        // 关联同一课程
        if let noteCourseid = note.relatedCourseId,
           let otherCourseId = other.relatedCourseId,
           noteCourseid == otherCourseId {
            score += 0.2
        }
        
        return min(score, 1.0)
    }
    
    // 自动为课程创建复习计划
    static func createReviewPlanForCourse(
        course: CourseItem,
        context: ModelContext
    ) -> [TodoItem] {
        let calendar = Calendar.current
        var todos: [TodoItem] = []
        
        // 期中复习（课程开始后8周）
        if let midtermDate = calendar.date(byAdding: .weekOfYear, value: 8, to: Date()) {
            let midterm = TodoItem(
                title: "[\(course.courseName)] 期中复习",
                notes: "准备期中考试",
                priority: .high,
                dueDate: midtermDate,
                category: "复习",
                estimatedPomodoros: 8
            )
            context.insert(midterm)
            todos.append(midterm)
        }
        
        // 期末复习（课程开始后16周）
        if let finalDate = calendar.date(byAdding: .weekOfYear, value: 16, to: Date()) {
            let final = TodoItem(
                title: "[\(course.courseName)] 期末复习",
                notes: "准备期末考试",
                priority: .urgent,
                dueDate: finalDate,
                category: "复习",
                estimatedPomodoros: 16
            )
            context.insert(final)
            todos.append(final)
        }
        
        return todos
    }
}

