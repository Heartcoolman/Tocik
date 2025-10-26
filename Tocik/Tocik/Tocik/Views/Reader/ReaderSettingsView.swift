//
//  ReaderSettingsView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct ReaderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fontSize: CGFloat
    @Binding var backgroundColor: Color
    @Binding var textColor: Color
    
    let themes: [(name: String, bg: Color, text: Color)] = [
        ("浅色", .white, .black),
        ("深色", .black, .white),
        ("护眼", Color(hex: "#C7EDCC"), Color(hex: "#2C3E50")),
        ("夜间", Color(hex: "#2C3E50"), Color(hex: "#ECF0F1"))
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("字体大小") {
                    HStack {
                        Text("A")
                            .font(.system(size: 14))
                        
                        Slider(value: $fontSize, in: 12...32, step: 2)
                        
                        Text("A")
                            .font(.system(size: 24))
                    }
                    
                    Text("预览文字")
                        .font(.system(size: fontSize))
                }
                
                Section("主题") {
                    ForEach(themes, id: \.name) { theme in
                        Button(action: {
                            backgroundColor = theme.bg
                            textColor = theme.text
                        }) {
                            HStack {
                                Circle()
                                    .fill(theme.bg)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                
                                Text(theme.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if backgroundColor == theme.bg && textColor == theme.text {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ReaderSettingsView(
        fontSize: .constant(18),
        backgroundColor: .constant(.white),
        textColor: .constant(.black)
    )
}

