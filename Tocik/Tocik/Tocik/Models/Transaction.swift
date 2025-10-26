//
//  Transaction.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var transactionType: TransactionType
    var category: String
    var note: String
    var date: Date
    var createdDate: Date
    
    // v4.0 新增字段
    @Attribute(.externalStorage) var receiptImageData: Data? // 收据照片
    var accountName: String // 账户名称
    var isRecurring: Bool // 是否为定期账单
    var recurringDay: Int? // 每月定期日期（1-31）
    var tags: String // 标签，逗号分隔
    
    enum TransactionType: String, Codable {
        case income = "收入"
        case expense = "支出"
        
        var colorHex: String {
            switch self {
            case .income: return "#4ECDC4"
            case .expense: return "#FF6B6B"
            }
        }
    }
    
    init(amount: Double, transactionType: TransactionType, category: String, note: String = "", date: Date = Date(), accountName: String = "默认账户") {
        self.id = UUID()
        self.amount = amount
        self.transactionType = transactionType
        self.category = category
        self.note = note
        self.date = date
        self.createdDate = Date()
        
        // v4.0 初始化
        self.receiptImageData = nil
        self.accountName = accountName
        self.isRecurring = false
        self.recurringDay = nil
        self.tags = ""
    }
}

@Model
final class Budget {
    var id: UUID
    var monthYear: String // "2025-10" 格式
    var totalBudget: Double
    var categoryBudgetsData: String // JSON字符串存储
    
    // v4.0 新增字段
    var warningThreshold: Double // 预警阈值（百分比，如80表示80%）
    var accountBudgets: String // 各账户预算（JSON格式）
    
    // 计算属性
    var categoryBudgets: [String: Double] {
        get {
            guard !categoryBudgetsData.isEmpty,
                  let data = categoryBudgetsData.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: Double].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                categoryBudgetsData = string
            }
        }
    }
    
    init(monthYear: String, totalBudget: Double, categoryBudgets: [String: Double] = [:], warningThreshold: Double = 80.0) {
        self.id = UUID()
        self.monthYear = monthYear
        self.totalBudget = totalBudget
        
        if let data = try? JSONEncoder().encode(categoryBudgets),
           let string = String(data: data, encoding: .utf8) {
            self.categoryBudgetsData = string
        } else {
            self.categoryBudgetsData = ""
        }
        
        // v4.0 初始化
        self.warningThreshold = warningThreshold
        self.accountBudgets = "{}"
    }
    
    // 检查是否需要预警
    func shouldWarn(currentSpending: Double) -> Bool {
        let percentage = (currentSpending / totalBudget) * 100
        return percentage >= warningThreshold
    }
}

