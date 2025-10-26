//
//  LoadingSkeletonView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 骨架屏加载效果
//

import SwiftUI

struct LoadingSkeletonView: View {
    @State private var animating = false
    
    var body: some View {
        VStack(spacing: 16) {
            SkeletonLine(width: .infinity, height: 60)
            SkeletonLine(width: 200, height: 20)
            SkeletonLine(width: 150, height: 20)
            
            HStack(spacing: 12) {
                SkeletonLine(width: 100, height: 100)
                SkeletonLine(width: 100, height: 100)
                SkeletonLine(width: 100, height: 100)
            }
        }
        .padding()
    }
}

struct SkeletonLine: View {
    let width: CGFloat?
    let height: CGFloat
    @State private var animating = false
    
    init(width: CGFloat?, height: CGFloat) {
        if let w = width {
            self.width = w == .infinity ? nil : w
        } else {
            self.width = nil
        }
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.4),
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: animating ? .leading : .trailing,
                    endPoint: animating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

// 卡片骨架
struct CardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonLine(width: 150, height: 20)
            SkeletonLine(width: nil, height: 60)
            HStack {
                SkeletonLine(width: 80, height: 15)
                Spacer()
                SkeletonLine(width: 60, height: 15)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

// 列表项骨架
struct ListItemSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonLine(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                SkeletonLine(width: 200, height: 16)
                SkeletonLine(width: 120, height: 12)
            }
            
            Spacer()
        }
        .padding()
    }
}

