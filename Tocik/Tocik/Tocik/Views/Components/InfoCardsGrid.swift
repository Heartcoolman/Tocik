//
//  InfoCardsGrid.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  信息卡片网格
//

import SwiftUI
import SwiftData

struct InfoCardsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ExamCountdownInfoCard()
            AIInsightsInfoCard()
            WeekStatsInfoCard()
        }
    }
}

struct ExamCountdownInfoCard: View {
    @Query private var exams: [Exam]
    
    private var nearestExam: Exam? {
        exams.filter { !$0.isFinished }.min(by: { $0.examDate < $1.examDate })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(Theme.examGradient)
                Spacer()
            }
            
            if let exam = nearestExam {
                Text(exam.examName)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(exam.daysRemaining())")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.examGradient)
                    Text("天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(exam.subject)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("暂无考试")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct AIInsightsInfoCard: View {
    @Query private var suggestions: [SmartSuggestion]
    @State private var showAI = false
    
    private var unreadCount: Int {
        suggestions.filter { !$0.isRead }.count
    }
    
    var body: some View {
        Button(action: { showAI = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain")
                        .font(.title2)
                        .foregroundStyle(Theme.primaryGradient)
                    Spacer()
                    if unreadCount > 0 {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text("AI建议")
                    .font(.headline)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(unreadCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.primaryGradient)
                    Text("条新建议")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showAI) {
            AIAssistantView()
        }
    }
}

struct WeekStatsInfoCard: View {
    @Query private var pomodoroSessions: [PomodoroSession]
    @State private var showStats = false
    
    private var weekCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return pomodoroSessions.filter { $0.startTime >= weekAgo && $0.isCompleted }.count
    }
    
    var body: some View {
        Button(action: { showStats = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.statsGradient)
                    Spacer()
                }
                
                Text("本周统计")
                    .font(.headline)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(weekCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.statsGradient)
                    Text("番茄钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("≈ \(String(format: "%.1f", Double(weekCount) * 0.5))小时")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showStats) {
            StatsView()
        }
    }
}

