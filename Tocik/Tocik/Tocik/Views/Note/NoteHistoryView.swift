//
//  NoteHistoryView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 笔记版本历史
//

import SwiftUI

struct NoteHistoryView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVersion: NoteVersion?
    @State private var showRestoreConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                // 当前版本
                Section("当前版本") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(note.content)
                            .font(.subheadline)
                            .lineLimit(3)
                        
                        HStack {
                            Text("最后修改")
                                .font(.caption)
                            Text(formatDate(note.modifiedDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 历史版本
                if note.versions.isEmpty {
                    Section {
                        Text("暂无历史版本")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    Section("历史版本 (\(note.versions.count))") {
                        ForEach(note.versions.sorted { $0.createdDate > $1.createdDate }) { version in
                            Button(action: {
                                selectedVersion = version
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(formatDate(version.createdDate))
                                            .font(.subheadline.bold())
                                        
                                        Spacer()
                                        
                                        Text(version.changeDescription)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text(version.content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("版本历史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedVersion) { version in
                VersionDetailView(
                    version: version,
                    onRestore: {
                        showRestoreConfirmation = true
                    }
                )
            }
            .alert("恢复版本？", isPresented: $showRestoreConfirmation) {
                Button("取消", role: .cancel) {
                    selectedVersion = nil
                }
                Button("恢复") {
                    if let version = selectedVersion {
                        note.restoreVersion(version)
                        selectedVersion = nil
                        dismiss()
                        HapticManager.shared.success()
                    }
                }
            } message: {
                Text("这将把笔记内容恢复到选定的版本，当前内容将保存为新版本")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct VersionDetailView: View {
    let version: NoteVersion
    let onRestore: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacing.large) {
                    // 版本信息
                    VStack(alignment: .leading, spacing: 8) {
                        Text("创建时间")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDate(version.createdDate))
                            .font(.subheadline.bold())
                        
                        Text("修改说明")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        Text(version.changeDescription)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    
                    // 内容
                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(version.content)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    
                    // 恢复按钮
                    Button(action: {
                        onRestore()
                        dismiss()
                    }) {
                        Label("恢复到此版本", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryGradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("版本详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

