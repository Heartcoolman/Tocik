//
//  VoiceMemoView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct VoiceMemoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VoiceMemo.createdDate, order: .reverse) private var memos: [VoiceMemo]
    
    @State private var showingRecorder = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if memos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("开始录制您的第一条语音")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(memos) { memo in
                            VoiceMemoRow(memo: memo)
                        }
                        .onDelete(perform: deleteMemos)
                    }
                }
            }
            .navigationTitle("语音备忘录")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingRecorder = true }) {
                        Image(systemName: "mic.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showingRecorder) {
                AudioRecorderView()
            }
        }
    }
    
    private func deleteMemos(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(memos[index])
        }
        try? modelContext.save()
    }
}

struct VoiceMemoRow: View {
    let memo: VoiceMemo
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(memo.title)
                    .font(Theme.bodyFont)
                
                Text(memo.formattedDuration())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !memo.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(memo.tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(memo.createdDate.formatted("MM/dd"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if memo.isTranscribed {
                    Image(systemName: "text.bubble.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AudioRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recorder = AudioRecorder()
    
    @State private var title = ""
    @State private var audioFileName: String?
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // 录音动画
                ZStack {
                    if recorder.isRecording {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .scaleEffect(recorder.isRecording ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: recorder.isRecording)
                    }
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // 时间显示
                Text(timeString(recorder.recordingTime))
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                
                Spacer()
                
                // 控制按钮
                if recorder.isRecording {
                    Button(action: stopRecording) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("停止录音")
                        }
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(Theme.cornerRadius)
                    }
                } else if audioFileName == nil {
                    Button(action: startRecording) {
                        HStack {
                            Image(systemName: "record.circle")
                            Text("开始录音")
                        }
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(Theme.cornerRadius)
                    }
                } else {
                    VStack(spacing: 16) {
                        TextField("语音标题", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button("保存") {
                            saveMemo()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(title.isEmpty)
                    }
                }
            }
            .padding()
            .navigationTitle("录音")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startRecording() {
        audioFileName = recorder.startRecording()
    }
    
    private func stopRecording() {
        duration = recorder.stopRecording()
    }
    
    private func saveMemo() {
        guard let fileName = audioFileName else { return }
        
        let memo = VoiceMemo(title: title, audioFileName: fileName, duration: duration)
        modelContext.insert(memo)
        try? modelContext.save()
        dismiss()
    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceMemoView()
        .modelContainer(for: VoiceMemo.self, inMemory: true)
}

