//
//  PersonalReport.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 个人成长报告
//

import Foundation
import SwiftData

@Model
final class PersonalReport {
    var id: UUID
    var reportType: ReportType
    var startDate: Date
    var endDate: Date
    var generatedDate: Date
    
    // 统计数据（JSON字符串）
    var pomodoroStatsData: String
    var todoStatsData: String
    var habitStatsData: String
    var studyStatsData: String
    
    // 分析结果
    var strengths: String // 强项，换行分隔
    var weaknesses: String // 弱项，换行分隔
    var suggestions: String // 建议，换行分隔
    var achievementsSummary: String
    
    enum ReportType: String, Codable {
        case weekly = "周报"
        case monthly = "月报"
        case quarterly = "季报"
        case yearly = "年报"
    }
    
    init(reportType: ReportType, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.reportType = reportType
        self.startDate = startDate
        self.endDate = endDate
        self.generatedDate = Date()
        self.pomodoroStatsData = "{}"
        self.todoStatsData = "{}"
        self.habitStatsData = "{}"
        self.studyStatsData = "{}"
        self.strengths = ""
        self.weaknesses = ""
        self.suggestions = ""
        self.achievementsSummary = ""
    }
    
    // 报告标题
    var title: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        
        switch reportType {
        case .weekly:
            formatter.dateFormat = "MM月dd日"
            return "\(formatter.string(from: startDate)) 周报"
        case .monthly:
            return "\(formatter.string(from: startDate)) 月报"
        case .quarterly:
            return "\(Calendar.current.component(.year, from: startDate))年 Q\((Calendar.current.component(.month, from: startDate) - 1) / 3 + 1) 季报"
        case .yearly:
            return "\(Calendar.current.component(.year, from: startDate))年 年报"
        }
    }
}

