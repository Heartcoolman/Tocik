//
//  UniversalSearchView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 全局搜索
//

import SwiftUI
import SwiftData

struct UniversalSearchView: View {
    @Query private var notes: [Note]
    @Query private var todos: [TodoItem]
    @Query private var flashCards: [FlashCard]
    @Query private var wrongQuestions: [WrongQuestion]
    @Query private var goals: [Goal]
    
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var searchResults: [SearchResult] = []
    
    enum SearchCategory: String, CaseIterable {
        case all = "全部"
        case notes = "笔记"
        case todos = "待办"
        case flashcards = "闪卡"
        case wrongQuestions = "错题"
        case goals = "目标"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding()
                
                // 分类选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SearchCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                performSearch()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                Divider()
                
                // 搜索结果
                if searchText.isEmpty {
                    EmptySearchView()
                } else if searchResults.isEmpty {
                    NoResultsView(searchText: searchText)
                } else {
                    SearchResultsList(results: filteredResults)
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: searchText) { oldValue, newValue in
            if !newValue.isEmpty {
                performSearch()
            } else {
                searchResults = []
            }
        }
    }
    
    private var filteredResults: [SearchResult] {
        if selectedCategory == .all {
            return searchResults
        }
        return searchResults.filter { $0.category == selectedCategory }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        var results: [SearchResult] = []
        let query = searchText.lowercased()
        
        // 搜索笔记
        if selectedCategory == .all || selectedCategory == .notes {
            let matchedNotes = notes.filter {
                $0.title.lowercased().contains(query) ||
                $0.content.lowercased().contains(query) ||
                $0.tags.contains(where: { $0.lowercased().contains(query) })
            }
            results.append(contentsOf: matchedNotes.map { SearchResult(from: $0) })
        }
        
        // 搜索待办
        if selectedCategory == .all || selectedCategory == .todos {
            let matchedTodos = todos.filter {
                $0.title.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query)
            }
            results.append(contentsOf: matchedTodos.map { SearchResult(from: $0) })
        }
        
        // 搜索闪卡
        if selectedCategory == .all || selectedCategory == .flashcards {
            let matchedCards = flashCards.filter {
                $0.question.lowercased().contains(query) ||
                $0.answer.lowercased().contains(query)
            }
            results.append(contentsOf: matchedCards.map { SearchResult(from: $0) })
        }
        
        // 搜索错题
        if selectedCategory == .all || selectedCategory == .wrongQuestions {
            let matchedQuestions = wrongQuestions.filter {
                $0.subject.lowercased().contains(query) ||
                $0.analysis.lowercased().contains(query)
            }
            results.append(contentsOf: matchedQuestions.map { SearchResult(from: $0) })
        }
        
        // 搜索目标
        if selectedCategory == .all || selectedCategory == .goals {
            let matchedGoals = goals.filter {
                $0.title.lowercased().contains(query) ||
                $0.goalDescription.lowercased().contains(query)
            }
            results.append(contentsOf: matchedGoals.map { SearchResult(from: $0) })
        }
        
        searchResults = results
    }
}

// MARK: - 搜索结果模型

struct SearchResult: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: UniversalSearchView.SearchCategory
    let icon: String
    let color: Color
    
    init(from note: Note) {
        self.id = note.id
        self.title = note.title
        self.subtitle = String(note.content.prefix(100))
        self.category = .notes
        self.icon = "doc.text"
        self.color = Theme.primaryColor
    }
    
    init(from todo: TodoItem) {
        self.id = todo.id
        self.title = todo.title
        self.subtitle = todo.notes
        self.category = .todos
        self.icon = "checkmark.circle"
        self.color = Theme.todoColor
    }
    
    init(from card: FlashCard) {
        self.id = card.id
        self.title = card.question
        self.subtitle = card.answer
        self.category = .flashcards
        self.icon = "rectangle.stack"
        self.color = Color(hex: "#8B5CF6")
    }
    
    init(from question: WrongQuestion) {
        self.id = question.id
        self.title = question.subject
        self.subtitle = question.analysis
        self.category = .wrongQuestions
        self.icon = "exclamationmark.triangle"
        self.color = .red
    }
    
    init(from goal: Goal) {
        self.id = goal.id
        self.title = goal.title
        self.subtitle = goal.goalDescription
        self.category = .goals
        self.icon = "target"
        self.color = Color(hex: goal.colorHex)
    }
}

// MARK: - 子视图

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索笔记、待办、闪卡...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    AnyShapeStyle(Theme.primaryGradient) :
                    AnyShapeStyle(.ultraThinMaterial)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("搜索全部内容")
                .font(.title2.bold())
            
            Text("输入关键词搜索笔记、待办、闪卡等")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: Theme.spacing.large) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("未找到结果")
                .font(.title2.bold())
            
            Text("没有找到包含\"\(searchText)\"的内容")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchResultsList: View {
    let results: [SearchResult]
    
    var body: some View {
        List {
            Section {
                Text("找到 \(results.count) 个结果")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(results) { result in
                SearchResultRow(result: result)
            }
        }
        .listStyle(.plain)
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(result.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: result.icon)
                    .foregroundColor(result.color)
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !result.subtitle.isEmpty {
                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(result.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(result.color.opacity(0.2))
                    .foregroundColor(result.color)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

