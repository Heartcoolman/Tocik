//
//  CSVImporter.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - CSV批量导入
//

import Foundation
import SwiftData

class CSVImporter {
    // 导入闪卡
    static func importFlashCards(
        from csvData: String,
        toDeck deck: FlashDeck,
        context: ModelContext
    ) throws -> Int {
        let lines = csvData.components(separatedBy: .newlines)
        var importedCount = 0
        
        // 跳过标题行
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            
            let columns = parseCSVLine(line)
            guard columns.count >= 2 else { continue }
            
            let question = columns[0]
            let answer = columns[1]
            let difficulty: FlashCard.Difficulty = columns.count > 2 ? parseDifficulty(columns[2]) : .medium
            let tags = columns.count > 3 ? columns[3].split(separator: "|").map { String($0) } : []
            
            let card = FlashCard(question: question, answer: answer, difficulty: difficulty)
            card.tags = tags
            
            deck.cards.append(card)
            context.insert(card)
            importedCount += 1
        }
        
        return importedCount
    }
    
    // 导入待办事项
    static func importTodos(
        from csvData: String,
        context: ModelContext
    ) throws -> Int {
        let lines = csvData.components(separatedBy: .newlines)
        var importedCount = 0
        
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            
            let columns = parseCSVLine(line)
            guard columns.count >= 1 else { continue }
            
            let title = columns[0]
            let notes = columns.count > 1 ? columns[1] : ""
            let priority: TodoItem.Priority = columns.count > 2 ? parsePriority(columns[2]) : .medium
            let category = columns.count > 3 ? columns[3] : "通用"
            let estimatedPomodoros = columns.count > 4 ? Int(columns[4]) ?? 1 : 1
            
            let todo = TodoItem(
                title: title,
                notes: notes,
                priority: priority,
                category: category,
                estimatedPomodoros: estimatedPomodoros
            )
            
            context.insert(todo)
            importedCount += 1
        }
        
        return importedCount
    }
    
    // 导入错题
    static func importWrongQuestions(
        from csvData: String,
        context: ModelContext
    ) throws -> Int {
        let lines = csvData.components(separatedBy: .newlines)
        var importedCount = 0
        
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            
            let columns = parseCSVLine(line)
            guard columns.count >= 2 else { continue }
            
            let subject = columns[0]
            let analysis = columns[1]
            let note = columns.count > 2 ? columns[2] : ""
            let errorType: WrongQuestion.ErrorType = columns.count > 3 ? parseErrorType(columns[3]) : .notUnderstand
            let knowledgePoints = columns.count > 4 ? columns[4] : ""
            
            let question = WrongQuestion(
                subject: subject,
                analysis: analysis,
                note: note,
                errorType: errorType
            )
            question.knowledgePoints = knowledgePoints
            
            context.insert(question)
            importedCount += 1
        }
        
        return importedCount
    }
    
    // CSV格式示例生成
    static func generateFlashCardTemplate() -> String {
        """
        问题,答案,难度,标签
        "什么是Swift?","Apple开发的编程语言","简单","编程|Swift"
        "什么是SwiftUI?","声明式UI框架","中等","SwiftUI|UI"
        """
    }
    
    static func generateTodoTemplate() -> String {
        """
        标题,备注,优先级,分类,预估番茄钟
        "学习Swift基础","完成第一章","高","学习",2
        "准备演讲PPT","需要包含案例","中","工作",4
        """
    }
    
    static func generateWrongQuestionTemplate() -> String {
        """
        科目,解析,笔记,错误类型,知识点
        "数学","勾股定理应用","需要记住公式","概念不清","勾股定理,三角形"
        "英语","过去完成时","时态混淆","未掌握","时态,语法"
        """
    }
    
    // MARK: - 辅助方法
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        
        columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
        return columns
    }
    
    private static func parseDifficulty(_ string: String) -> FlashCard.Difficulty {
        switch string.lowercased() {
        case "简单", "easy": return .easy
        case "困难", "hard": return .hard
        default: return .medium
        }
    }
    
    private static func parsePriority(_ string: String) -> TodoItem.Priority {
        switch string.lowercased() {
        case "低", "low": return .low
        case "高", "high": return .high
        case "紧急", "urgent": return .urgent
        default: return .medium
        }
    }
    
    private static func parseErrorType(_ string: String) -> WrongQuestion.ErrorType {
        switch string {
        case "粗心大意": return .careless
        case "概念不清": return .notUnderstand
        case "未掌握": return .notMaster
        case "计算错误": return .calculation
        case "审题不清": return .misread
        default: return .other
        }
    }
}

