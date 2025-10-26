//
//  ReadingPageView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct ReadingPageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let book: ReadingBook
    
    @State private var fontSize: CGFloat = 18
    @State private var showSettings = false
    @State private var backgroundColor: Color = .white
    @State private var textColor: Color = .black
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        Text(book.content)
                            .font(.system(size: fontSize))
                            .foregroundColor(textColor)
                            .padding()
                            .id("content")
                    }
                    .onAppear {
                        // 滚动到上次阅读位置（简化版）
                    }
                }
            }
            .navigationTitle(book.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        saveProgress()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "textformat.size")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                ReaderSettingsView(
                    fontSize: $fontSize,
                    backgroundColor: $backgroundColor,
                    textColor: $textColor
                )
            }
        }
    }
    
    private func saveProgress() {
        book.lastReadDate = Date()
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ReadingBook.self, configurations: config)
    
    let book = ReadingBook(
        fileName: "示例.txt",
        content: "这是一本示例书籍的内容。\n\n第一章\n\n这里是第一章的内容..."
    )
    
    return ReadingPageView(book: book)
        .modelContainer(container)
}

