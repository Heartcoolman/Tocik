//
//  PDFGenerator.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - PDF报告生成
//

import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    // 生成学习报告PDF
    static func generateStudyReport(
        report: PersonalReport,
        userName: String = "用户"
    ) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Tocik",
            kCGPDFContextTitle: report.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // 标题
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let title = report.title
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // 日期范围
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateRange = "\(dateFormatter.string(from: report.startDate)) - \(dateFormatter.string(from: report.endDate))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.gray
            ]
            dateRange.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // 分隔线
            drawLine(context: context.cgContext, from: CGPoint(x: 50, y: yPosition), to: CGPoint(x: pageWidth - 50, y: yPosition))
            yPosition += 20
            
            // 强项
            if !report.strengths.isEmpty {
                yPosition = drawSection(
                    context: context.cgContext,
                    title: "💪 优势",
                    content: report.strengths,
                    startY: yPosition,
                    pageWidth: pageWidth
                )
            }
            
            // 弱项
            if !report.weaknesses.isEmpty {
                yPosition = drawSection(
                    context: context.cgContext,
                    title: "📊 待提升",
                    content: report.weaknesses,
                    startY: yPosition,
                    pageWidth: pageWidth
                )
            }
            
            // 建议
            if !report.suggestions.isEmpty {
                yPosition = drawSection(
                    context: context.cgContext,
                    title: "💡 建议",
                    content: report.suggestions,
                    startY: yPosition,
                    pageWidth: pageWidth
                )
            }
            
            // 成就总结
            if !report.achievementsSummary.isEmpty {
                yPosition = drawSection(
                    context: context.cgContext,
                    title: "🏆 成就",
                    content: report.achievementsSummary,
                    startY: yPosition,
                    pageWidth: pageWidth
                )
            }
            
            // 页脚
            let footerText = "生成时间：\(dateFormatter.string(from: Date())) | Tocik v4.0"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.lightGray
            ]
            footerText.draw(at: CGPoint(x: 50, y: pageHeight - 30), withAttributes: footerAttributes)
        }
        
        return data
    }
    
    // 生成错题集PDF
    static func generateWrongQuestionsPDF(questions: [WrongQuestion]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Tocik",
            kCGPDFContextTitle: "错题集"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var currentPage = 0
            
            for (index, question) in questions.enumerated() {
                if index % 2 == 0 {
                    if index > 0 {
                        context.beginPage()
                    } else {
                        context.beginPage()
                    }
                    currentPage += 1
                }
                
                let yOffset: CGFloat = index % 2 == 0 ? 50 : pageHeight / 2 + 20
                
                // 题目编号和科目
                let headerText = "题目 \(index + 1) - \(question.subject)"
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                headerText.draw(at: CGPoint(x: 50, y: yOffset), withAttributes: headerAttributes)
                
                // 错误类型
                let typeText = "错误类型：\(question.errorType.rawValue)"
                let typeAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray
                ]
                typeText.draw(at: CGPoint(x: 50, y: yOffset + 25), withAttributes: typeAttributes)
                
                // 解析
                if !question.analysis.isEmpty {
                    let analysisText = "解析：\(question.analysis)"
                    let analysisAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor.darkGray
                    ]
                    let analysisRect = CGRect(x: 50, y: yOffset + 50, width: pageWidth - 100, height: 150)
                    analysisText.draw(in: analysisRect, withAttributes: analysisAttributes)
                }
            }
        }
        
        return data
    }
    
    // 辅助方法：绘制分段
    private static func drawSection(
        context: CGContext,
        title: String,
        content: String,
        startY: CGFloat,
        pageWidth: CGFloat
    ) -> CGFloat {
        var yPosition = startY
        
        // 标题
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        yPosition += 25
        
        // 内容
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        let contentRect = CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 200)
        content.draw(in: contentRect, withAttributes: contentAttributes)
        yPosition += 220
        
        return yPosition
    }
    
    // 辅助方法：绘制线条
    private static func drawLine(context: CGContext, from: CGPoint, to: CGPoint) {
        context.saveGState()
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
        context.restoreGState()
    }
}

