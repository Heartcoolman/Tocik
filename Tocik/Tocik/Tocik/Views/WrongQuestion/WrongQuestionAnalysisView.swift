//
//  WrongQuestionAnalysisView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 错题分析
//

import SwiftUI
import SwiftData
import Charts

struct WrongQuestionAnalysisView: View {
    @Query private var wrongQuestions: [WrongQuestion]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 总体统计
                OverallStatsSection(
                    total: wrongQuestions.count,
                    notMastered: notMasteredCount,
                    reviewing: reviewingCount,
                    mastered: masteredCount
                )
                
                // 科目分布
                SubjectDistributionSection(data: subjectDistribution)
                
                // 错误类型分析
                ErrorTypeAnalysisSection(data: errorTypeDistribution)
                
                // 知识点统计
                KnowledgePointsSection(points: topKnowledgePoints)
                
                // 复习建议
                ReviewSuggestionsSection(questions: needReviewQuestions)
                
                // 举一反三
                RelatedQuestionsSection(questions: wrongQuestions.prefix(5).map { $0 })
            }
            .padding()
        }
        .navigationTitle("错题分析")
    }
    
    // MARK: - 计算属性
    
    private var notMasteredCount: Int {
        wrongQuestions.filter { $0.masteryLevel == .notMastered }.count
    }
    
    private var reviewingCount: Int {
        wrongQuestions.filter { $0.masteryLevel == .reviewing }.count
    }
    
    private var masteredCount: Int {
        wrongQuestions.filter { $0.masteryLevel == .mastered }.count
    }
    
    private var subjectDistribution: [(String, Int)] {
        let grouped = Dictionary(grouping: wrongQuestions) { $0.subject }
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
    }
    
    private var errorTypeDistribution: [(WrongQuestion.ErrorType, Int)] {
        let grouped = Dictionary(grouping: wrongQuestions) { $0.errorType }
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
    }
    
    private var topKnowledgePoints: [(String, Int)] {
        var pointsCount: [String: Int] = [:]
        
        for question in wrongQuestions {
            let points = question.knowledgePoints.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            for point in points where !point.isEmpty {
                pointsCount[point, default: 0] += 1
            }
        }
        
        return pointsCount.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
            .prefix(10)
            .map { $0 }
    }
    
    private var needReviewQuestions: [WrongQuestion] {
        wrongQuestions.filter { $0.nextReviewDate <= Date() && $0.masteryLevel != .mastered }
    }
}

// MARK: - 子视图

struct OverallStatsSection: View {
    let total: Int
    let notMastered: Int
    let reviewing: Int
    let mastered: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("总体统计")
                .font(Theme.titleFont)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.small) {
                MasteryStatCard(title: "未掌握", count: notMastered, color: .red)
                MasteryStatCard(title: "复习中", count: reviewing, color: .orange)
                MasteryStatCard(title: "已掌握", count: mastered, color: .green)
            }
            
            // 掌握率
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("掌握率")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(masteryPercentage)%")
                        .font(.headline.bold())
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * CGFloat(masteryPercentage) / 100.0)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var masteryPercentage: Int {
        guard total > 0 else { return 0 }
        return Int(Double(mastered) / Double(total) * 100)
    }
}

struct MasteryStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SubjectDistributionSection: View {
    let data: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("科目分布")
                .font(Theme.titleFont)
            
            if #available(iOS 16.0, *) {
                Chart(data, id: \.0) { subject, count in
                    SectorMark(
                        angle: .value("数量", count),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("科目", subject))
                    .cornerRadius(5)
                }
                .frame(height: 250)
                .chartLegend(position: .bottom, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(data, id: \.0) { subject, count in
                        HStack {
                            Text(subject)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct ErrorTypeAnalysisSection: View {
    let data: [(WrongQuestion.ErrorType, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("错误类型分析")
                .font(Theme.titleFont)
            
            VStack(spacing: 12) {
                ForEach(data, id: \.0.rawValue) { errorType, count in
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: errorType.colorHex))
                                .frame(width: 12, height: 12)
                            
                            Text(errorType.rawValue)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.subheadline.bold())
                        
                        // 百分比条
                        let maxCount = data.first?.1 ?? 1
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: errorType.colorHex))
                                .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount))
                        }
                        .frame(width: 60, height: 8)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct KnowledgePointsSection: View {
    let points: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("高频知识点")
                .font(Theme.titleFont)
            
            if points.isEmpty {
                Text("暂无知识点标签")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(points, id: \.0) { point, count in
                        HStack(spacing: 4) {
                            Text(point)
                            Text("×\(count)")
                                .font(.caption2)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct ReviewSuggestionsSection: View {
    let questions: [WrongQuestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("待复习")
                    .font(Theme.titleFont)
                
                Spacer()
                
                Text("\(questions.count)道")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            if questions.isEmpty {
                Text("太棒了！暂无需要复习的错题")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(questions.prefix(5)) { question in
                        HStack {
                            Circle()
                                .fill(Color(hex: question.errorType.colorHex))
                                .frame(width: 8, height: 8)
                            
                            Text(question.subject)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(daysOverdue(question.nextReviewDate))
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func daysOverdue(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days > 0 {
            return "逾期\(days)天"
        } else {
            return "今日"
        }
    }
}

struct RelatedQuestionsSection: View {
    let questions: [WrongQuestion]
    
    // 根据知识点分组
    private var knowledgeGroups: [String: [WrongQuestion]] {
        var groups: [String: [WrongQuestion]] = [:]
        
        for question in questions {
            let points = question.knowledgePoints.isEmpty ? ["未分类"] : question.knowledgePoints.split(separator: ",").map { String($0) }
            for point in points {
                if groups[point] == nil {
                    groups[point] = []
                }
                groups[point]?.append(question)
            }
        }
        
        return groups.filter { $0.value.count > 1 } // 只显示有多个错题的知识点
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("举一反三")
                .font(Theme.titleFont)
            
            Text("相同知识点的错题会自动关联，帮助您系统化复习")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if knowledgeGroups.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "network.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("暂无关联的错题")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("为错题添加知识点标签后，系统会自动建立关联")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                // 知识点网络图
                KnowledgeNetworkView(knowledgeGroups: knowledgeGroups)
                
                // 知识点列表
                VStack(spacing: 12) {
                    ForEach(Array(knowledgeGroups.keys.sorted()), id: \.self) { knowledge in
                        KnowledgePointRow(
                            knowledgePoint: knowledge,
                            questionCount: knowledgeGroups[knowledge]?.count ?? 0
                        )
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

// MARK: - 知识点网络图

struct KnowledgeNetworkView: View {
    let knowledgeGroups: [String: [WrongQuestion]]
    
    private var topKnowledgePoints: [(String, Int)] {
        knowledgeGroups
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { ($0.0, $0.1) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 连接线
                ForEach(Array(topKnowledgePoints.enumerated()), id: \.offset) { index, _ in
                    ForEach((index + 1)..<topKnowledgePoints.count, id: \.self) { otherIndex in
                        Path { path in
                            let start = nodePosition(for: index, total: topKnowledgePoints.count, in: geometry.size)
                            let end = nodePosition(for: otherIndex, total: topKnowledgePoints.count, in: geometry.size)
                            path.move(to: start)
                            path.addLine(to: end)
                        }
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    }
                }
                
                // 节点
                ForEach(Array(topKnowledgePoints.enumerated()), id: \.offset) { index, item in
                    let (knowledge, count) = item
                    let position = nodePosition(for: index, total: topKnowledgePoints.count, in: geometry.size)
                    
                    NetworkNode(
                        label: knowledge,
                        count: count,
                        size: nodeSize(for: count)
                    )
                    .position(position)
                }
            }
        }
        .frame(height: 200)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func nodePosition(for index: Int, total: Int, in size: CGSize) -> CGPoint {
        let angle = (Double(index) / Double(total)) * 2 * .pi - .pi / 2
        let radius = min(size.width, size.height) * 0.35
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        return CGPoint(
            x: centerX + CGFloat(cos(angle)) * radius,
            y: centerY + CGFloat(sin(angle)) * radius
        )
    }
    
    private func nodeSize(for count: Int) -> CGFloat {
        return CGFloat(min(30 + count * 5, 60))
    }
}

struct NetworkNode: View {
    let label: String
    let count: Int
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: size, height: size)
                
                Text("\(count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.caption2)
                .lineLimit(1)
                .frame(maxWidth: size * 1.5)
        }
    }
}

struct KnowledgePointRow: View {
    let knowledgePoint: String
    let questionCount: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.primaryGradient)
                .frame(width: 8, height: 8)
            
            Text(knowledgePoint)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(questionCount)道")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

