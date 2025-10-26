//
//  MultiTypeCardStudyView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 多题型闪卡学习
//

import SwiftUI
import AVFoundation

struct MultiTypeCardStudyView: View {
    @Bindable var card: FlashCard
    @StateObject private var tts = TextToSpeech()
    
    @State private var showAnswer = false
    @State private var userAnswer = ""
    @State private var selectedOption: String?
    
    var body: some View {
        VStack(spacing: Theme.spacing.xlarge) {
            // 卡片类型指示器
            CardTypeIndicator(cardType: card.cardType)
            
            // 问题区域
            QuestionSection(
                card: card,
                onSpeak: {
                    if card.enableVoiceReading {
                        tts.speak(text: card.question)
                    }
                }
            )
            
            // 根据题型显示不同的答题界面
            answerSection
            
            Spacer()
            
            // 操作按钮
            if !showAnswer {
                Button(action: { withAnimation { showAnswer = true } }) {
                    Text("显示答案")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.flashcardGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // 答案显示
                AnswerSection(card: card)
                
                // 评价按钮
                FeedbackButtons(
                    onRemember: {
                        handleAnswer(remembered: true)
                    },
                    onForget: {
                        handleAnswer(remembered: false)
                    }
                )
            }
        }
        .padding()
        .onDisappear {
            tts.stop()
        }
    }
    
    @ViewBuilder
    private var answerSection: some View {
        switch card.cardType {
        case .basic:
            // 基础问答型，不需要输入
            EmptyView()
            
        case .fillBlank:
            // 填空题
            VStack(alignment: .leading, spacing: 8) {
                Text("您的答案：")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("在此输入答案", text: $userAnswer)
                    .textFieldStyle(.roundedBorder)
                    .disabled(showAnswer)
            }
            
        case .multipleChoice:
            // 选择题
            if let optionsData = card.options.data(using: .utf8),
               let options = try? JSONDecoder().decode([String].self, from: optionsData) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("选项：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        OptionButton(
                            letter: String(UnicodeScalar(65 + index)!),
                            text: option,
                            isSelected: selectedOption == option,
                            isCorrect: showAnswer && option == card.answer,
                            action: {
                                if !showAnswer {
                                    selectedOption = option
                                    HapticManager.shared.selection()
                                }
                            }
                        )
                    }
                }
            }
            
        case .matching:
            // 匹配题
            MatchingQuestionView(
                card: card,
                showAnswer: showAnswer
            )
        }
    }
    
    private func handleAnswer(remembered: Bool) {
        // 使用SM-2算法更新复习时间
        let (newInterval, newEaseFactor, nextReviewDate) = SM2Algorithm.simpleReview(
            card: card,
            remembered: remembered
        )
        
        // 更新卡片数据
        card.reviewCount += 1
        if remembered {
            card.correctCount += 1
        }
        card.lastReviewDate = Date()
        card.interval = newInterval
        card.easeFactor = newEaseFactor
        card.nextReviewDate = nextReviewDate
        
        // 记录学习曲线数据
        recordLearningProgress(remembered: remembered)
        
        HapticManager.shared.success()
    }
    
    private func recordLearningProgress(remembered: Bool) {
        // 将学习进度添加到学习曲线数据
        let progress = LearningProgress(
            date: Date(),
            remembered: remembered,
            interval: card.interval
        )
        
        // 解析现有数据
        var progressArray: [LearningProgress] = []
        if let data = card.learningCurveData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([LearningProgress].self, from: data) {
            progressArray = decoded
        }
        
        // 添加新记录
        progressArray.append(progress)
        
        // 保存（保留最近100条）
        if progressArray.count > 100 {
            progressArray = Array(progressArray.suffix(100))
        }
        
        if let encoded = try? JSONEncoder().encode(progressArray),
           let jsonString = String(data: encoded, encoding: .utf8) {
            card.learningCurveData = jsonString
        }
    }
}

// MARK: - 学习进度记录

struct LearningProgress: Codable {
    let date: Date
    let remembered: Bool
    let interval: Int
}

struct CardTypeIndicator: View {
    let cardType: FlashCard.CardType
    
    var body: some View {
        HStack {
            Image(systemName: cardType.icon)
            Text(cardType.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.flashcardGradient.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct QuestionSection: View {
    let card: FlashCard
    let onSpeak: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("问题")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if card.enableVoiceReading {
                    Button(action: onSpeak) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Text(card.question)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 提示
            if !card.hint.isEmpty {
                DisclosureGroup("💡 提示") {
                    Text(card.hint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

struct AnswerSection: View {
    let card: FlashCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("答案")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(card.answer)
                .font(.title3.bold())
                .foregroundColor(.green)
            
            if !card.explanation.isEmpty {
                Divider()
                
                Text("解释")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(card.explanation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Color.green.opacity(0.3), lineWidth: 2)
        )
        .transition(.scale.combined(with: .opacity))
    }
}

struct OptionButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 选项字母
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Text(letter)
                        .font(.subheadline.bold())
                        .foregroundColor(textColor)
                }
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(backgroundMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isCorrect { return .green }
        if isSelected { return .blue }
        return .gray.opacity(0.3)
    }
    
    private var textColor: Color {
        if isCorrect || isSelected { return .white }
        return .primary
    }
    
    private var backgroundMaterial: Material {
        if isCorrect { return .ultraThin }
        return .ultraThinMaterial
    }
    
    private var borderColor: Color {
        if isCorrect { return .green }
        if isSelected { return .blue }
        return .clear
    }
}

struct FeedbackButtons: View {
    let onRemember: () -> Void
    let onForget: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.spacing.medium) {
            Button(action: onForget) {
                VStack {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                    Text("不记得")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(action: onRemember) {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                    Text("记得")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - 匹配题视图

struct MatchingQuestionView: View {
    let card: FlashCard
    let showAnswer: Bool
    
    @State private var matchings: [String: String] = [:] // 左项 -> 右项
    @State private var selectedLeft: String?
    
    // 解析匹配题数据
    private var pairs: [(left: String, right: String)] {
        guard let optionsData = card.options.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: String].self, from: optionsData) else {
            return []
        }
        return decoded.map { (left: $0.key, right: $0.value) }
    }
    
    private var leftItems: [String] {
        pairs.map { $0.left }
    }
    
    private var rightItems: [String] {
        pairs.map { $0.right }.shuffled()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("点击左侧项目，再点击右侧项目进行配对")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .top, spacing: 20) {
                // 左列
                VStack(spacing: 12) {
                    ForEach(leftItems, id: \.self) { item in
                        MatchingItemButton(
                            text: item,
                            isSelected: selectedLeft == item,
                            isMatched: matchings[item] != nil,
                            isCorrect: showAnswer && matchings[item] == correctMatch(for: item),
                            action: {
                                if !showAnswer {
                                    selectedLeft = item
                                    HapticManager.shared.selection()
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                
                // 连接线提示
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 右列
                VStack(spacing: 12) {
                    ForEach(rightItems, id: \.self) { item in
                        MatchingItemButton(
                            text: item,
                            isSelected: matchings.values.contains(item),
                            isMatched: matchings.values.contains(item),
                            isCorrect: showAnswer && isCorrectMatch(rightItem: item),
                            action: {
                                if !showAnswer, let left = selectedLeft {
                                    matchings[left] = item
                                    selectedLeft = nil
                                    HapticManager.shared.success()
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // 清除按钮
            if !showAnswer && !matchings.isEmpty {
                Button(action: {
                    matchings.removeAll()
                    selectedLeft = nil
                }) {
                    Text("清除所有配对")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func correctMatch(for leftItem: String) -> String {
        pairs.first { $0.left == leftItem }?.right ?? ""
    }
    
    private func isCorrectMatch(rightItem: String) -> Bool {
        matchings.contains { pair in
            let correctRight = pairs.first { $0.left == pair.key }?.right
            return pair.value == rightItem && correctRight == rightItem
        }
    }
}

struct MatchingItemButton: View {
    let text: String
    let isSelected: Bool
    let isMatched: Bool
    let isCorrect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isMatched {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isCorrect { return .green.opacity(0.1) }
        if isMatched { return .blue.opacity(0.05) }
        if isSelected { return .blue.opacity(0.1) }
        return .gray.opacity(0.05)
    }
    
    private var borderColor: Color {
        if isCorrect { return .green }
        if isSelected { return .blue }
        if isMatched { return .blue.opacity(0.3) }
        return .gray.opacity(0.2)
    }
}

