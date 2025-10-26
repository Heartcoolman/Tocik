//
//  InspirationView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct InspirationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Inspiration.createdDate, order: .reverse) private var inspirations: [Inspiration]
    
    @State private var showingAdd = false
    @State private var filterStatus: Inspiration.Status?
    
    var filteredInspirations: [Inspiration] {
        if let status = filterStatus {
            return inspirations.filter { $0.status == status }
        }
        return inspirations
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if inspirations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("记录您的灵感火花")
                            .font(Theme.headlineFont)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(filteredInspirations) { inspiration in
                            InspirationRow(inspiration: inspiration)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        modelContext.delete(inspiration)
                                        try? modelContext.save()
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        cycleStatus(inspiration)
                                    } label: {
                                        Label("切换状态", systemImage: "arrow.triangle.2.circlepath")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("灵感收集箱")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { filterStatus = nil }) {
                            Label("全部", systemImage: filterStatus == nil ? "checkmark" : "")
                        }
                        
                        ForEach(Inspiration.Status.allCases, id: \.self) { status in
                            Button(action: { filterStatus = status }) {
                                Label(status.rawValue, systemImage: filterStatus == status ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddInspirationView()
            }
        }
    }
    
    private func cycleStatus(_ inspiration: Inspiration) {
        switch inspiration.status {
        case .pending:
            inspiration.status = .implemented
        case .implemented:
            inspiration.status = .archived
        case .archived:
            inspiration.status = .pending
        }
        inspiration.updatedDate = Date()
        try? modelContext.save()
    }
}

struct InspirationRow: View {
    let inspiration: Inspiration
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: inspiration.inspirationType.icon)
                .foregroundColor(.yellow)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(inspiration.title)
                    .font(Theme.bodyFont)
                
                Text(inspiration.content)
                    .font(Theme.captionFont)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(inspiration.inspirationType.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(inspiration.status.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: inspiration.status.colorHex).opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddInspirationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var content = ""
    @State private var inspirationType: Inspiration.InspirationType = .idea
    @State private var linkedUrl = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }
                
                Section("类型") {
                    Picker("类型", selection: $inspirationType) {
                        ForEach(Inspiration.InspirationType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }
                
                if inspirationType == .link {
                    Section("链接") {
                        TextField("https://", text: $linkedUrl)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            .navigationTitle("新建灵感")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveInspiration()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveInspiration() {
        let inspiration = Inspiration(
            title: title,
            content: content,
            inspirationType: inspirationType,
            linkedUrl: linkedUrl.isEmpty ? nil : linkedUrl
        )
        
        modelContext.insert(inspiration)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    InspirationView()
        .modelContainer(for: Inspiration.self, inMemory: true)
}

