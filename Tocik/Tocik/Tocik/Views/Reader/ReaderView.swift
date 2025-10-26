//
//  ReaderView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ReaderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [ReadingBook]
    
    @State private var showingFilePicker = false
    @State private var showingWebDAV = false
    @State private var selectedBook: ReadingBook?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if books.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("导入TXT文件开始阅读")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(books) { book in
                            BookRow(book: book)
                                .onTapGesture {
                                    selectedBook = book
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        modelContext.delete(book)
                                        try? modelContext.save()
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("阅读器")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingWebDAV = true }) {
                        Image(systemName: "externaldrive.badge.icloud")
                            .foregroundColor(Theme.readerColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilePicker = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.readerColor)
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker { url in
                    importBook(from: url)
                }
            }
            .sheet(isPresented: $showingWebDAV) {
                WebDAVBrowserView()
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReadingPageView(book: book)
            }
        }
    }
    
    private func importBook(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let book = ReadingBook(
                fileName: url.lastPathComponent,
                content: content,
                source: .local
            )
            modelContext.insert(book)
            try? modelContext.save()
        } catch {
            print("导入文件失败: \(error)")
        }
    }
}

struct BookRow: View {
    let book: ReadingBook
    
    private var readingProgress: Double {
        guard book.content.count > 0 else { return 0 }
        return Double(book.currentPosition) / Double(book.content.count) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(book.fileName)
                    .font(Theme.bodyFont)
                
                Spacer()
                
                if book.source == .webdav {
                    Image(systemName: "icloud.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            
            HStack {
                Text("上次阅读：\(book.lastReadDate.timeAgoDisplay())")
                    .font(Theme.captionFont)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(readingProgress))%")
                    .font(Theme.captionFont)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.readerColor)
                        .frame(width: geometry.size.width * readingProgress / 100)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 4)
    }
}

// DocumentPicker for importing files
struct DocumentPicker: UIViewControllerRepresentable {
    let onPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.plainText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPicked: (URL) -> Void
        
        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPicked(url)
        }
    }
}

#Preview {
    ReaderView()
        .modelContainer(for: ReadingBook.self, inMemory: true)
}

