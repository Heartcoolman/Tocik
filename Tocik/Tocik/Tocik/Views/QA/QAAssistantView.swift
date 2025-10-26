//
//  QAAssistantView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  答疑助手视图（集成OCR + DeepSeek）
//

import SwiftUI
import SwiftData

struct QAAssistantView: View {
    @Query(sort: \QASession.createdDate, order: .reverse) private var sessions: [QASession]
    @State private var showAskQuestion = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 头部
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.primaryGradient)
                    Text("AI答疑助手")
                        .font(.title2.bold())
                    Text("拍照识题，AI秒答")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // 提问按钮
                Button(action: { showAskQuestion = true }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("拍照提问")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                
                // 历史记录
                if !sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("历史记录")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(sessions.prefix(10)) { session in
                            QASessionCard(session: session)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("答疑助手")
        .sheet(isPresented: $showAskQuestion) {
            AskQuestionView()
        }
    }
}

struct QASessionCard: View {
    let session: QASession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.subject)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                Spacer()
                Text(session.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(session.question)
                .font(.subheadline)
                .lineLimit(2)
            
            if !session.aiAnswer.isEmpty {
                Text(session.aiAnswer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct AskQuestionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    
    @State private var question = ""
    @State private var subject = "数学"
    @State private var difficulty: QASession.Difficulty = .medium
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var aiAnswer = ""
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 拍照/选择图片
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .topTrailing) {
                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                            }
                    } else {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                Button(action: { showCamera = true }) {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                        Text("拍照")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Button(action: { showImagePicker = true }) {
                                    VStack {
                                        Image(systemName: "photo.fill")
                                            .font(.largeTitle)
                                        Text("相册")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    
                    // 问题输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("问题")
                            .font(.headline)
                        TextField("输入问题或点击上方拍照识别", text: $question, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...10)
                    }
                    
                    // 科目和难度
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("科目")
                                .font(.subheadline)
                            TextField("科目", text: $subject)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("难度")
                                .font(.subheadline)
                            Picker("", selection: $difficulty) {
                                Text("简单").tag(QASession.Difficulty.easy)
                                Text("中等").tag(QASession.Difficulty.medium)
                                Text("困难").tag(QASession.Difficulty.hard)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    // AI解答按钮
                    Button(action: getAIAnswer) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                                Text("AI思考中...")
                            } else {
                                Image(systemName: "brain")
                                Text("AI解答")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(question.isEmpty || isProcessing)
                    
                    // AI答案显示
                    if !aiAnswer.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("AI解答", systemImage: "brain.head.profile")
                                .font(.headline)
                                .foregroundStyle(Theme.primaryGradient)
                            
                            Text(aiAnswer)
                                .font(.subheadline)
                            
                            HStack {
                                Button("保存到错题本") {
                                    saveToWrongQuestions()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("创建闪卡") {
                                    createFlashCard()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("提问")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if !aiAnswer.isEmpty {
                        Button("保存") {
                            saveSession()
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { _, _ in
                if selectedImage != nil {
                    performOCR()
                }
            }
        }
    }
    
    private func performOCR() {
        guard let image = selectedImage else { return }
        
        isProcessing = true
        OCRManager.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success(let text):
                    question = text
                case .failure:
                    break
                }
            }
        }
    }
    
    private func getAIAnswer() {
        Task { [self] in
            await MainActor.run {
                self.isProcessing = true
            }
            
            let prompt = """
            这是一道\(self.subject)题目：
            
            \(self.question)
            
            请详细解答，包括：
            1. 解题思路
            2. 详细步骤
            3. 知识点总结
            4. 易错提示
            """
            
            let (answer, tokens) = await DeepSeekManager.shared.chatWithTokenTracking(userMessage: prompt)
            
            // 记录token消耗
            if let profile = self.userProfiles.first, tokens > 0 {
                await MainActor.run {
                    profile.recordTokenUsage(tokens: tokens, callType: .qa)
                }
            }
            
            if let answer = answer {
                await MainActor.run {
                    self.aiAnswer = answer
                    self.isProcessing = false
                    print("✅ AI答疑完成 - 消耗 \(tokens) tokens")
                }
            } else {
                await MainActor.run {
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func saveSession() {
        let session = QASession(
            question: question,
            subject: subject,
            difficulty: difficulty,
            questionImageData: selectedImage?.pngData()
        )
        session.aiAnswer = aiAnswer
        context.insert(session)
        HapticManager.shared.success()
    }
    
    private func saveToWrongQuestions() {
        let wrongQ = WrongQuestion(
            subject: subject,
            analysis: aiAnswer,
            note: question
        )
        context.insert(wrongQ)
        try? context.save()
        HapticManager.shared.success()
    }
    
    private func createFlashCard() {
        let card = FlashCard(
            question: question,
            answer: aiAnswer
        )
        context.insert(card)
        try? context.save()
        HapticManager.shared.success()
    }
}


