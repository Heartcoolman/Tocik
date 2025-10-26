//
//  EnhancedVoiceMemoView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 增强语音备忘录
//

import SwiftUI
import SwiftData

struct EnhancedVoiceMemoView: View {
    @Bindable var memo: VoiceMemo
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var transcript = ""
    @State private var isTranscribing = false
    @State private var extractedKeywords: [String] = []
    @State private var showCreateTodo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.large) {
                // 录音信息
                MemoInfoCard(memo: memo)
                
                // 转文字按钮
                if transcript.isEmpty {
                    Button(action: transcribeAudio) {
                        HStack {
                            if isTranscribing {
                                ProgressView()
                                    .tint(.white)
                                Text("识别中...")
                            } else {
                                Image(systemName: "text.bubble")
                                Text("转换为文字")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isTranscribing)
                } else {
                    // 转录文字
                    TranscriptCard(
                        transcript: transcript,
                        keywords: extractedKeywords
                    )
                    
                    // 操作按钮
                    HStack(spacing: Theme.spacing.medium) {
                        Button(action: { showCreateTodo = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "checklist")
                                Text("创建待办")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.todoGradient.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: copyTranscript) {
                            VStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("复制")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(memo.title)
        .sheet(isPresented: $showCreateTodo) {
            CreateTodoFromTranscriptView(transcript: transcript)
        }
    }
    
    private func transcribeAudio() {
        guard let audioURL = getAudioURL() else { return }
        
        isTranscribing = true
        
        Task {
            do {
                let text = try await speechRecognizer.transcribe(audioFileURL: audioURL)
                transcript = text
                extractedKeywords = extractKeywords(from: text)
                isTranscribing = false
                HapticManager.shared.success()
            } catch {
                isTranscribing = false
                print("转录失败: \(error)")
            }
        }
    }
    
    private func getAudioURL() -> URL? {
        // 从Documents目录获取音频文件
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let audioURL = documentsPath.appendingPathComponent(memo.audioFileName)
        
        // 检查文件是否存在
        if fileManager.fileExists(atPath: audioURL.path) {
            return audioURL
        } else {
            print("音频文件不存在: \(audioURL.path)")
            return nil
        }
    }
    
    private func extractKeywords(from text: String) -> [String] {
        // 简单的关键词提取（可以使用更复杂的NLP算法）
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let filtered = words.filter { $0.count > 2 }
        
        // 词频统计
        let counts = Dictionary(grouping: filtered) { $0.lowercased() }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return Array(counts.prefix(5).map { $0.key })
    }
    
    private func copyTranscript() {
        UIPasteboard.general.string = transcript
        HapticManager.shared.success()
    }
}

struct MemoInfoCard: View {
    let memo: VoiceMemo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .font(.title)
                    .foregroundStyle(Theme.primaryGradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(memo.title)
                        .font(.headline)
                    
                    HStack {
                        Text(formatDuration(memo.duration))
                            .font(.caption)
                        
                        Text("·")
                            .font(.caption)
                        
                        Text(formatDate(memo.createdDate))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !memo.tagsData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(memo.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TranscriptCard: View {
    let transcript: String
    let keywords: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text("转录文字")
                .font(Theme.titleFont)
            
            Text(transcript)
                .font(.subheadline)
                .textSelection(.enabled)
            
            if !keywords.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("关键词")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(keywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
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

struct CreateTodoFromTranscriptView: View {
    let transcript: String
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: TodoItem.Priority = .medium
    
    var body: some View {
        NavigationStack {
            Form {
                Section("任务信息") {
                    TextField("任务标题", text: $title)
                    
                    Picker("优先级", selection: $priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("创建待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        let todo = TodoItem(
                            title: title.isEmpty ? "语音任务" : title,
                            notes: notes.isEmpty ? transcript : notes,
                            priority: priority,
                            category: "语音任务"
                        )
                        context.insert(todo)
                        dismiss()
                        HapticManager.shared.success()
                    }
                }
            }
            .onAppear {
                notes = transcript
                // 尝试从转录文字中提取标题
                if let firstSentence = transcript.split(separator: "。").first {
                    title = String(firstSentence.prefix(50))
                }
            }
        }
    }
}

