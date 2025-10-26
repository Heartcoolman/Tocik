//
//  TimeBlockView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 时间块可视化
//

import SwiftUI

struct TimeBlockView: View {
    let timeBlocks: [TimeBlock]
    let date: Date
    
    private let hourHeight: CGFloat = 60
    private let hours = Array(0...23)
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // 时间轴
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HStack {
                            Text(String(format: "%02d:00", hour))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)
                            
                            Divider()
                            
                            Spacer()
                        }
                        .frame(height: hourHeight)
                    }
                }
                
                // 时间块
                ForEach(timeBlocks) { block in
                    TimeBlockBar(block: block, hourHeight: hourHeight)
                        .padding(.leading, 60)
                }
            }
            .padding()
        }
        .navigationTitle(formatDate(date))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

struct TimeBlock: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let title: String
    let type: BlockType
    let color: Color
    
    enum BlockType {
        case pomodoro
        case course
        case event
        case habit
        case other
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}

struct TimeBlockBar: View {
    let block: TimeBlock
    let hourHeight: CGFloat
    
    var body: some View {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: block.startTime)
        let startMinute = calendar.component(.minute, from: block.startTime)
        
        let topOffset = (CGFloat(startHour) + CGFloat(startMinute) / 60.0) * hourHeight
        let height = CGFloat(block.duration / 3600.0) * hourHeight
        
        VStack(alignment: .leading, spacing: 2) {
            Text(block.title)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(timeRangeText)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: max(height, 40))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(block.color.gradient)
        )
        .shadow(color: block.color.opacity(0.3), radius: 4, x: 0, y: 2)
        .offset(y: topOffset)
    }
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: block.startTime)) - \(formatter.string(from: block.endTime))"
    }
}

