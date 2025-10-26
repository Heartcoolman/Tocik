//
//  LearningCurveView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 学习曲线可视化
//

import SwiftUI
import Charts

struct LearningCurveView: View {
    @Bindable var deck: FlashDeck
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.xlarge) {
                // 卡片组概览
                DeckOverviewCard(deck: deck)
                
                // 掌握度分布
                MasteryDistributionChart(cards: deck.cards)
                
                // 复习时间线
                ReviewTimelineChart(cards: deck.cards)
                
                // 正确率趋势
                AccuracyTrendChart(cards: deck.cards)
                
                // 需要复习的卡片
                NeedReviewSection(cards: needReviewCards)
            }
            .padding()
        }
        .navigationTitle("学习曲线")
    }
    
    private var needReviewCards: [FlashCard] {
        deck.cards.filter { $0.nextReviewDate <= Date() }.sorted { $0.nextReviewDate < $1.nextReviewDate }
    }
}

struct DeckOverviewCard: View {
    let deck: FlashDeck
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            // 标题
            Text(deck.name)
                .font(.title.bold())
            
            // 统计
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                OverviewStat(title: "总卡片", value: "\(deck.cards.count)", icon: "rectangle.stack")
                OverviewStat(title: "待复习", value: "\(deck.cardsNeedReview())", icon: "clock.badge.exclamationmark", color: .orange)
                OverviewStat(title: "平均正确率", value: "\(Int(averageAccuracy * 100))%", icon: "chart.line.uptrend.xyaxis", color: .green)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var averageAccuracy: Double {
        guard !deck.cards.isEmpty else { return 0 }
        let total = deck.cards.map { $0.accuracyRate }.reduce(0, +)
        return total / Double(deck.cards.count)
    }
}

struct OverviewStat: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .blue
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MasteryDistributionChart: View {
    let cards: [FlashCard]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("掌握度分布")
                .font(Theme.titleFont)
            
            if cards.isEmpty {
                Text("暂无卡片")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if #available(iOS 16.0, *) {
                Chart {
                    ForEach(masteryData, id: \.0) { level, count in
                        SectorMark(
                            angle: .value("数量", count),
                            innerRadius: .ratio(0.618)
                        )
                        .foregroundStyle(by: .value("掌握度", level))
                        .cornerRadius(5)
                    }
                }
                .frame(height: 200)
            }
            
            // 图例
            HStack(spacing: 16) {
                FlashCardLegendItem(color: .red, label: "困难(\(difficultCount))")
                FlashCardLegendItem(color: .orange, label: "中等(\(mediumCount))")
                FlashCardLegendItem(color: .green, label: "简单(\(easyCount))")
            }
            .font(.caption)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var masteryData: [(String, Int)] {
        [
            ("困难", difficultCount),
            ("中等", mediumCount),
            ("简单", easyCount)
        ].filter { $0.1 > 0 }
    }
    
    private var difficultCount: Int {
        cards.filter { $0.difficulty == .hard }.count
    }
    
    private var mediumCount: Int {
        cards.filter { $0.difficulty == .medium }.count
    }
    
    private var easyCount: Int {
        cards.filter { $0.difficulty == .easy }.count
    }
}

struct FlashCardLegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }
}

struct ReviewTimelineChart: View {
    let cards: [FlashCard]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("复习时间线")
                .font(Theme.titleFont)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(next7Days, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text(formatDay(date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ZStack {
                                Circle()
                                    .fill(cardsForDate(date) > 0 ? Theme.flashcardGradient : LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 50, height: 50)
                                
                                Text("\(cardsForDate(date))")
                                    .font(.headline.bold())
                                    .foregroundColor(cardsForDate(date) > 0 ? .white : .secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var next7Days: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: Date())
        }
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func cardsForDate(_ date: Date) -> Int {
        cards.filter {
            Calendar.current.isDate($0.nextReviewDate, inSameDayAs: date)
        }.count
    }
}

struct AccuracyTrendChart: View {
    let cards: [FlashCard]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("正确率趋势")
                .font(Theme.titleFont)
            
            if cards.filter({ $0.reviewCount > 0 }).isEmpty {
                Text("开始学习后会显示趋势")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                // 显示最近复习的卡片的正确率
                VStack(spacing: 8) {
                    ForEach(recentReviewedCards) { card in
                        HStack {
                            Text(String(card.question.prefix(30)))
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(Int(card.accuracyRate * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(accuracyColor(card.accuracyRate))
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(accuracyGradient(card.accuracyRate))
                                    .frame(width: geo.size.width * card.accuracyRate)
                            }
                            .frame(width: 60, height: 6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private var recentReviewedCards: [FlashCard] {
        cards.filter { $0.reviewCount > 0 }
            .sorted { ($0.lastReviewDate ?? Date.distantPast) > ($1.lastReviewDate ?? Date.distantPast) }
            .prefix(10)
            .map { $0 }
    }
    
    private func accuracyColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .green }
        if rate >= 0.6 { return .orange }
        return .red
    }
    
    private func accuracyGradient(_ rate: Double) -> LinearGradient {
        if rate >= 0.8 {
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        } else if rate >= 0.6 {
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct NeedReviewSection: View {
    let cards: [FlashCard]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("待复习")
                    .font(Theme.titleFont)
                
                Spacer()
                
                if !cards.isEmpty {
                    Text("\(cards.count)张")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            
            if cards.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("太棒了！暂无需要复习的卡片")
                        .font(.subheadline)
                }
                .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(cards.prefix(10)) { card in
                        HStack {
                            Circle()
                                .fill(Color(hex: card.difficulty.colorHex))
                                .frame(width: 8, height: 8)
                            
                            Text(card.question)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(daysOverdue(card.nextReviewDate))
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
        } else if Calendar.current.isDateInToday(date) {
            return "今天"
        } else {
            return "即将到期"
        }
    }
}

