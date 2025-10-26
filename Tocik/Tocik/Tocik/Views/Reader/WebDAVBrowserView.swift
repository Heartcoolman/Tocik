//
//  WebDAVBrowserView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct WebDAVBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var webdavManager = WebDAVManager.shared
    
    @State private var showingConfig = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !webdavManager.isConnected {
                    VStack(spacing: 20) {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("未连接到WebDAV服务器")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                        
                        Button("配置服务器") {
                            showingConfig = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if webdavManager.isLoading {
                    ProgressView("加载中...")
                } else if let errorMessage = webdavManager.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("重试") {
                            Task {
                                await webdavManager.listFiles(path: webdavManager.currentPath)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(webdavManager.files) { file in
                            HStack {
                                Image(systemName: file.isDirectory ? "folder.fill" : "doc.text.fill")
                                    .foregroundColor(file.isDirectory ? .blue : .secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(file.name)
                                        .font(Theme.bodyFont)
                                    
                                    if let size = file.size, !file.isDirectory {
                                        Text(formatFileSize(size))
                                            .font(Theme.captionFont)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if file.isDirectory {
                                    Task {
                                        await webdavManager.listFiles(path: file.path)
                                    }
                                } else if file.name.hasSuffix(".txt") {
                                    downloadFile(file)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("WebDAV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingConfig = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingConfig) {
                WebDAVConfigView()
            }
        }
    }
    
    private func downloadFile(_ file: WebDAVManager.WebDAVFile) {
        Task {
            if let content = await webdavManager.downloadFile(file: file) {
                let book = ReadingBook(
                    fileName: file.name,
                    content: content,
                    source: .webdav,
                    webdavPath: file.path
                )
                await MainActor.run {
                    modelContext.insert(book)
                    try? modelContext.save()
                    dismiss()
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    WebDAVBrowserView()
        .modelContainer(for: ReadingBook.self, inMemory: true)
}

