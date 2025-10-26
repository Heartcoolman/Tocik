//
//  NoteTemplatePickerView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 笔记模板选择器
//

import SwiftUI
import SwiftData

struct NoteTemplatePickerView: View {
    @Query private var templates: [NoteTemplate]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    let onSelect: (NoteTemplate) -> Void
    
    @State private var showCreateTemplate = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.large) {
                    // 内置模板
                    if !builtInTemplates.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                            Text("内置模板")
                                .font(Theme.headlineFont)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                                ForEach(builtInTemplates) { template in
                                    TemplateCard(template: template) {
                                        onSelect(template)
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 自定义模板
                    if !customTemplates.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
                            Text("我的模板")
                                .font(Theme.headlineFont)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing.medium) {
                                ForEach(customTemplates) { template in
                                    TemplateCard(template: template) {
                                        onSelect(template)
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 空白笔记
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "doc")
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text("空白笔记")
                                    .font(.headline)
                                Text("从头开始创建")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeTemplatesIfNeeded()
            }
        }
    }
    
    private var builtInTemplates: [NoteTemplate] {
        templates.filter { $0.isBuiltIn }
    }
    
    private var customTemplates: [NoteTemplate] {
        templates.filter { !$0.isBuiltIn }
    }
    
    private func initializeTemplatesIfNeeded() {
        // 如果没有内置模板，创建它们
        if builtInTemplates.isEmpty {
            let defaults = NoteTemplate.createBuiltInTemplates()
            for template in defaults {
                context.insert(template)
            }
        }
    }
}

struct TemplateCard: View {
    let template: NoteTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.spacing.small) {
                // 图标
                Image(systemName: template.icon)
                    .font(.title)
                    .foregroundStyle(LinearGradient(
                        colors: [Color(hex: template.colorHex), Color(hex: template.colorHex).opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                // 标题
                Text(template.name)
                    .font(.headline)
                
                // 描述
                Text(template.templateDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                // 使用次数
                HStack {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                    Text("\(template.usageCount)次")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .frame(height: 140)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color(hex: template.colorHex).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

