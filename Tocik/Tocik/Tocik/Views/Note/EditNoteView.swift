//
//  EditNoteView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let note: Note?
    let relatedCourseId: UUID?
    let courseName: String?
    
    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var tags: [String]
    @State private var isPinned: Bool
    @State private var showingPreview = false
    @State private var newTag = ""
    
    init(note: Note?, relatedCourseId: UUID? = nil, courseName: String? = nil) {
        self.note = note
        self.relatedCourseId = relatedCourseId
        self.courseName = courseName
        _title = State(initialValue: note?.title ?? (courseName.map { "\($0) - " } ?? ""))
        _content = State(initialValue: note?.content ?? "")
        _category = State(initialValue: note?.category ?? courseName ?? "通用")
        _tags = State(initialValue: note?.tags ?? [])
        _isPinned = State(initialValue: note?.isPinned ?? false)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 标题
                TextField("标题", text: $title)
                    .font(Theme.headlineFont)
                    .padding()
                    .background(Color(.systemBackground))
                
                Divider()
                
                // 内容编辑器
                if showingPreview {
                    ScrollView {
                        Text(content)
                            .font(Theme.bodyFont)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    TextEditor(text: $content)
                        .font(Theme.bodyFont)
                        .padding(.horizontal, 8)
                }
                
                Divider()
                
                // 底部工具栏
                HStack {
                    TextField("分类", text: $category)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(.caption)
                                    
                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.noteColor.opacity(0.2))
                                .cornerRadius(4)
                            }
                            
                            TextField("添加标签", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                                .onSubmit {
                                    addTag()
                                }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle(note == nil ? "新建笔记" : "编辑笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showingPreview.toggle() }) {
                            Image(systemName: showingPreview ? "pencil" : "eye")
                        }
                        
                        Button(action: { isPinned.toggle() }) {
                            Image(systemName: isPinned ? "pin.fill" : "pin")
                                .foregroundColor(isPinned ? Theme.noteColor : .primary)
                        }
                        
                        Button("保存") {
                            saveNote()
                        }
                        .disabled(title.isBlank)
                    }
                }
            }
        }
    }
    
    private func addTag() {
        guard !newTag.isBlank, !tags.contains(newTag) else { return }
        tags.append(newTag)
        newTag = ""
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveNote() {
        if let note = note {
            // 更新现有笔记
            note.title = title
            note.content = content
            note.category = category
            note.tags = tags
            note.isPinned = isPinned
            note.modifiedDate = Date()
        } else {
            // 创建新笔记
            let newNote = Note(
                title: title,
                content: content,
                category: category,
                tags: tags,
                isPinned: isPinned,
                relatedCourseId: relatedCourseId
            )
            modelContext.insert(newNote)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    EditNoteView(note: nil)
        .modelContainer(for: Note.self, inMemory: true)
}

