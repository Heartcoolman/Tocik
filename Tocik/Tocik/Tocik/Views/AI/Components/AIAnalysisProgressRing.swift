//
//  AIAnalysisProgressRing.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  AI分析进度环形组件
//

import SwiftUI

struct AIAnalysisProgressRing: View {
    let progress: Double // 0-1
    let dataReadiness: Double // 0-1
    let acceptanceRate: Double // 0-1
    
    var body: some View {
        ZStack {
            // 多重进度环
            MultiProgressRingView(
                rings: [
                    MultiProgressRingView.RingData(
                        progress: progress,
                        gradient: Theme.primaryGradient,
                        label: "分析完成度"
                    ),
                    MultiProgressRingView.RingData(
                        progress: dataReadiness,
                        gradient: Theme.statsGradient,
                        label: "数据充足度"
                    ),
                    MultiProgressRingView.RingData(
                        progress: acceptanceRate,
                        gradient: Theme.habitGradient,
                        label: "建议接受率"
                    )
                ],
                size: 220
            )
            
            // 中心数字显示
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryGradient)
                
                Text("分析完成")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 240, height: 240)
    }
}

#Preview {
    AIAnalysisProgressRing(
        progress: 0.75,
        dataReadiness: 0.9,
        acceptanceRate: 0.65
    )
    .padding()
}

