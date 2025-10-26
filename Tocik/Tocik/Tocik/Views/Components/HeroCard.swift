//
//  HeroCard.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct HeroCard: View {
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            Text(title)
                .font(Theme.heroFont)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            Text(subtitle)
                .font(Theme.headlineFont)
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.spacing.xlarge)
        .background(
            ZStack {
                gradient
                
                // 装饰圆圈
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: 100, y: -50)
                    .blur(radius: 40)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -80, y: 80)
                    .blur(radius: 60)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.heroCornerRadius))
        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
    }
}

#Preview {
    HeroCard(
        title: "Tocik",
        subtitle: "您的多功能工具集合",
        gradient: Theme.primaryMeshGradient
    )
    .padding()
}

