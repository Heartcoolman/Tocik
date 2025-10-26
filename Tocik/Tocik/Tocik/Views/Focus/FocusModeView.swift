//
//  FocusModeView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import AVFoundation
import Combine

struct FocusModeView: View {
    @StateObject private var audioManager = WhiteNoiseManager()
    @State private var selectedSound: WhiteNoise = .rain
    @State private var volume: Double = 0.5
    @State private var isPlaying = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 播放器控制
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Theme.focusColor.opacity(0.2))
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .fill(Theme.focusColor.opacity(0.3))
                                .frame(width: 160, height: 160)
                            
                            Image(systemName: selectedSound.icon)
                                .font(.system(size: 60))
                                .foregroundColor(Theme.focusColor)
                        }
                        
                        Text(selectedSound.name)
                            .font(Theme.titleFont)
                        
                        // 播放/暂停按钮
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Theme.focusColor)
                        }
                        
                        // 音量控制
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.secondary)
                                
                                Slider(value: $volume, in: 0...1)
                                    .accentColor(Theme.focusColor)
                                    .onChange(of: volume) { oldValue, newValue in
                                        audioManager.setVolume(Float(newValue))
                                    }
                                
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(Theme.cornerRadius)
                    }
                    .padding()
                    
                    // 声音选择
                    VStack(alignment: .leading, spacing: 16) {
                        Text("选择白噪音")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(WhiteNoise.allCases, id: \.self) { sound in
                                SoundCard(
                                    sound: sound,
                                    isSelected: selectedSound == sound
                                ) {
                                    selectedSound = sound
                                    if isPlaying {
                                        audioManager.play(sound: sound)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 说明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("专注提示")
                            .font(Theme.headlineFont)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "headphones", text: "建议佩戴耳机以获得最佳体验")
                            TipRow(icon: "speaker.slash.fill", text: "环境声音有助于集中注意力")
                            TipRow(icon: "moon.zzz.fill", text: "同样适合睡眠和放松")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(Theme.cornerRadius)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("专注模式")
        }
        .onDisappear {
            audioManager.stop()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioManager.stop()
        } else {
            audioManager.play(sound: selectedSound)
        }
        isPlaying.toggle()
    }
}

struct SoundCard: View {
    let sound: WhiteNoise
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: sound.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : Theme.focusColor)
                
                Text(sound.name)
                    .font(Theme.bodyFont)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(isSelected ? Theme.focusColor : Color(.systemBackground))
            .cornerRadius(Theme.cornerRadius)
            .shadow(radius: 2)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.focusColor)
                .frame(width: 24)
            
            Text(text)
                .font(Theme.bodyFont)
                .foregroundColor(.secondary)
        }
    }
}

enum WhiteNoise: String, CaseIterable {
    case rain = "雨声"
    case ocean = "海浪"
    case forest = "森林"
    case fire = "篝火"
    case wind = "风声"
    case cafe = "咖啡厅"
    
    var name: String { rawValue }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "waveform"
        case .forest: return "leaf.fill"
        case .fire: return "flame.fill"
        case .wind: return "wind"
        case .cafe: return "cup.and.saucer.fill"
        }
    }
}

@MainActor
class WhiteNoiseManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func play(sound: WhiteNoise) {
        // 注意：实际应用中需要添加真实的音频文件
        // 这里只是演示代码结构
        print("播放: \(sound.name)")
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
}

#Preview {
    FocusModeView()
}

