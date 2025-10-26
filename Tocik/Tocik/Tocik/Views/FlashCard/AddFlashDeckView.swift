//
//  AddFlashDeckView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct AddFlashDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [CourseItem]
    
    @State private var name = ""
    @State private var deckDescription = ""
    @State private var selectedColor = "#4A90E2"
    @State private var relatedCourseId: UUID?
    
    let colors = ["#4A90E2", "#FF6B6B", "#4ECDC4", "#FFD93D", "#A78BFA", "#FB923C"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("卡片组名称", text: $name)
                    TextField("描述（可选）", text: $deckDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("关联课程") {
                    Picker("关联课程（可选）", selection: $relatedCourseId) {
                        Text("无关联").tag(nil as UUID?)
                        ForEach(courses) { course in
                            Text(course.courseName).tag(course.id as UUID?)
                        }
                    }
                }
                
                Section("颜色") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("新建卡片组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        saveDeck()
                    }
                    .disabled(name.isBlank)
                }
            }
        }
    }
    
    private func saveDeck() {
        let deck = FlashDeck(
            name: name,
            deckDescription: deckDescription,
            colorHex: selectedColor,
            relatedCourseId: relatedCourseId
        )
        modelContext.insert(deck)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddFlashDeckView()
        .modelContainer(for: [FlashDeck.self, CourseItem.self], inMemory: true)
}

