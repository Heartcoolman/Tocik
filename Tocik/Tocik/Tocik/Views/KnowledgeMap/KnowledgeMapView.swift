//
//  KnowledgeMapView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/24.
//  知识图谱视图
//

import SwiftUI
import SwiftData

struct KnowledgeMapView: View {
    @Query private var nodes: [KnowledgeNode]
    @State private var selectedSubject = "全部"
    @State private var showAddNode = false
    @State private var selectedNode: KnowledgeNode?
    
    var filteredNodes: [KnowledgeNode] {
        if selectedSubject == "全部" {
            return nodes
        }
        return nodes.filter { $0.subject == selectedSubject }
    }
    
    var subjects: [String] {
        var subs = Array(Set(nodes.map { $0.subject }))
        subs.insert("全部", at: 0)
        return subs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 科目筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(subjects, id: \.self) { subject in
                        SubjectFilterButton(
                            subject: subject,
                            isSelected: selectedSubject == subject,
                            action: { selectedSubject = subject }
                        )
                    }
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            // 知识点网络图
            if filteredNodes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "network")
                        .font(.system(size: 80))
                        .foregroundStyle(Theme.primaryGradient)
                    
                    Text("还没有知识点")
                        .font(.title2.bold())
                    
                    Text("点击右上角添加第一个知识点")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredNodes) { node in
                            KnowledgeNodeCard(node: node)
                                .onTapGesture {
                                    selectedNode = node
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("知识图谱")
        .toolbar {
            Button(action: { showAddNode = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showAddNode) {
            AddKnowledgeNodeView()
        }
        .sheet(item: $selectedNode) { node in
            KnowledgeNodeDetailView(node: node)
        }
    }
}

struct KnowledgeNodeCard: View {
    let node: KnowledgeNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: typeIcon)
                    .foregroundColor(Color(hex: Theme.subjectColors[node.subject] ?? "#667EEA"))
                Spacer()
                Text("\(node.masteryLevel)%")
                    .font(.caption.bold())
                    .foregroundColor(masteryColor)
            }
            
            Text(node.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(node.nodeType.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
            
            // 掌握度进度条
            ProgressView(value: Double(node.masteryLevel) / 100.0)
                .tint(masteryColor)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var typeIcon: String {
        switch node.nodeType {
        case .concept: return "lightbulb.fill"
        case .theorem: return "book.fill"
        case .formula: return "function"
        case .skill: return "star.fill"
        case .topic: return "folder.fill"
        }
    }
    
    private var masteryColor: Color {
        if node.masteryLevel >= 80 { return .green }
        if node.masteryLevel >= 50 { return .orange }
        return .red
    }
}

struct SubjectFilterButton: View {
    let subject: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(subject)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Theme.primaryGradient
                    } else {
                        Color.gray.opacity(0.1)
                    }
                }
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct AddKnowledgeNodeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var subject = ""
    @State private var nodeType: KnowledgeNode.NodeType = .concept
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("知识点名称", text: $title)
                TextField("科目", text: $subject)
                Picker("类型", selection: $nodeType) {
                    Text("概念").tag(KnowledgeNode.NodeType.concept)
                    Text("定理").tag(KnowledgeNode.NodeType.theorem)
                    Text("公式").tag(KnowledgeNode.NodeType.formula)
                    Text("技巧").tag(KnowledgeNode.NodeType.skill)
                    Text("主题").tag(KnowledgeNode.NodeType.topic)
                }
                TextField("描述", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("添加知识点")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let node = KnowledgeNode(
                            title: title,
                            subject: subject,
                            nodeType: nodeType,
                            description: description
                        )
                        context.insert(node)
                        dismiss()
                    }
                    .disabled(title.isEmpty || subject.isEmpty)
                }
            }
        }
    }
}

struct KnowledgeNodeDetailView: View {
    @Bindable var node: KnowledgeNode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 掌握度调整
                    VStack(alignment: .leading, spacing: 8) {
                        Text("掌握度")
                            .font(.headline)
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(node.masteryLevel) },
                                set: { node.masteryLevel = Int($0) }
                            ), in: 0...100, step: 5)
                            
                            Text("\(node.masteryLevel)%")
                                .font(.headline.bold())
                                .frame(width: 60)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 描述
                    if !node.nodeDescription.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述")
                                .font(.headline)
                            Text(node.nodeDescription)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle(node.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("完成") { dismiss() }
            }
        }
    }
}

