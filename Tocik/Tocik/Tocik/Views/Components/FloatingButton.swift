//
//  FloatingButton.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct FloatingButton: View {
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(gradient)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 25, x: 0, y: 15)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PressButtonStyle(isPressed: $isPressed))
    }
}

struct PressButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                withAnimation(Theme.bounceAnimation) {
                    isPressed = newValue
                }
            }
    }
}

#Preview {
    FloatingButton(
        icon: "play.fill",
        gradient: Theme.pomodoroGradient,
        action: {}
    )
    .padding()
}

