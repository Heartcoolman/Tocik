//
//  DeepSeekChatView.swift
//  Tocik
//
//  DeepSeek AI 智能对话界面
//

import SwiftUI
import SwiftData

struct DeepSeekChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = DeepSeekManager.shared
    
    @Query private var pomodoroSessions: [PomodoroSession]
    @Query private var todos: [TodoItem]
    @Query private var habits: [Habit]
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 消息列表
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                if messages.isEmpty {
                                    welcomeSection
                                } else {
                                    ForEach(messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                }
                                
                                if manager.isProcessing {
                                    typingIndicator
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                
                // 输入框
                inputBar
            }
            .navigationTitle("AI 学习助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("快速分析") {
                            quickAnalysis()
                        }
                        
                        Button("学习计划") {
                            createPlan()
                        }
                        
                        Divider()
                        
                        Button("清空对话") {
                            messages.removeAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("你好！我是你的 AI 学习助手")
                .font(.title2.bold())
            
            Text("我可以帮你：")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                quickActionButton(
                    icon: "chart.bar.fill",
                    title: "分析学习数据",
                    subtitle: "深度分析你的学习模式"
                ) {
                    quickAnalysis()
                }
                
                quickActionButton(
                    icon: "lightbulb.fill",
                    title: "诊断学习问题",
                    subtitle: "找出效率瓶颈"
                ) {
                    diagnoseProblem()
                }
                
                quickActionButton(
                    icon: "calendar",
                    title: "制定学习计划",
                    subtitle: "个性化学习路线"
                ) {
                    createPlan()
                }
            }
            .padding()
        }
        .padding()
    }
    
    private func quickActionButton(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#667EEA").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(typingAnimation ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: typingAnimation
                        )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onAppear {
                typingAnimation = true
            }
            
            Spacer()
        }
    }
    
    @State private var typingAnimation = false
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("输入你的问题...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .lineLimit(1...5)
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: inputText.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        inputText.isEmpty
                            ? LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(
                                colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            }
            .disabled(inputText.isEmpty || manager.isProcessing)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: inputText)
        messages.append(userMessage)
        
        let messageText = inputText
        inputText = ""
        
        Task {
            if let response = await manager.chat(userMessage: messageText) {
                let aiMessage = ChatMessage(role: .assistant, content: response)
                messages.append(aiMessage)
                HapticManager.shared.success()
            } else if let error = manager.lastError {
                let errorMessage = ChatMessage(role: .assistant, content: "❌ \(error)")
                messages.append(errorMessage)
                HapticManager.shared.error()
            }
        }
    }
    
    private func quickAnalysis() {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let recentPomodoros = pomodoroSessions.filter { $0.startTime > weekAgo && $0.isCompleted }
        let completedTodos = todos.filter { $0.isCompleted && $0.completedDate ?? Date.distantPast > weekAgo }
        let activeHabits = habits
        
        let studyHours = Double(recentPomodoros.count) * 0.5
        let maxStreak = activeHabits.map { $0.getCurrentStreak() }.max() ?? 0
        
        let pattern = """
        - 最常学习时段：\(getMostProductiveTime())
        - 平均每天番茄钟：\(recentPomodoros.count / 7) 个
        - 待办完成率：\(String(format: "%.0f", Double(completedTodos.count) / max(1.0, Double(todos.count)) * 100))%
        """
        
        Task {
            let userMessage = ChatMessage(role: .user, content: "请分析我的学习数据")
            messages.append(userMessage)
            
            if let response = await manager.analyzeStudyData(
                pomodoroCount: recentPomodoros.count,
                completedTodos: completedTodos.count,
                totalTodos: todos.count,
                studyHours: studyHours,
                habitStreak: maxStreak,
                recentPattern: pattern
            ) {
                let aiMessage = ChatMessage(role: .assistant, content: response)
                messages.append(aiMessage)
                HapticManager.shared.success()
            }
        }
    }
    
    private func diagnoseProblem() {
        inputText = "我最近学习效率不高，总是容易分心，该怎么办？"
    }
    
    private func createPlan() {
        inputText = "请帮我制定一个提高学习效率的计划"
    }
    
    private func getMostProductiveTime() -> String {
        let calendar = Calendar.current
        let hours = pomodoroSessions.map { calendar.component(.hour, from: $0.startTime) }
        
        guard !hours.isEmpty else { return "暂无数据" }
        
        let frequency = hours.reduce(into: [:]) { counts, hour in
            counts[hour, default: 0] += 1
        }
        
        let mostCommonHour = frequency.max(by: { $0.value < $1.value })?.key ?? 9
        
        return "\(mostCommonHour):00-\(mostCommonHour + 1):00"
    }
}

// MARK: - Supporting Views

struct MessageBubble: View {
    let message: ChatMessage
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var maxBubbleWidth: CGFloat {
        // iPad 用更大的宽度，iPhone 用固定宽度
        horizontalSizeClass == .regular ? 500 : 280
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .padding(12)
                    .background(
                        message.role == .user
                            ? LinearGradient(
                                colors: [Color(hex: "#667EEA"), Color(hex: "#48C6EF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: maxBubbleWidth, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

// MARK: - Models

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()
    
    enum Role {
        case user
        case assistant
    }
}

