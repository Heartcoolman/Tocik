//
//  StudyGroupView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 学习小组
//

import SwiftUI
import SwiftData

struct StudyGroupView: View {
    @Query private var groups: [StudyGroup]
    @Environment(\.modelContext) private var context
    
    @State private var showCreateGroup = false
    @State private var showJoinGroup = false
    
    var body: some View {
        NavigationStack {
            Group {
                if groups.isEmpty {
                    EmptyGroupView(
                        onCreateGroup: { showCreateGroup = true },
                        onJoinGroup: { showJoinGroup = true }
                    )
                } else {
                    List {
                        ForEach(groups.sorted { $0.createdDate > $1.createdDate }) { group in
                            NavigationLink {
                                StudyGroupDetailView(group: group)
                            } label: {
                                StudyGroupRow(group: group)
                            }
                        }
                        .onDelete(perform: deleteGroup)
                    }
                }
            }
            .navigationTitle("学习小组")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showCreateGroup = true }) {
                            Label("创建小组", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showJoinGroup = true }) {
                            Label("加入小组", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateStudyGroupView()
            }
            .sheet(isPresented: $showJoinGroup) {
                JoinStudyGroupView()
            }
        }
    }
    
    private func deleteGroup(at offsets: IndexSet) {
        for index in offsets {
            let group = groups.sorted { $0.createdDate > $1.createdDate }[index]
            context.delete(group)
        }
    }
}

struct EmptyGroupView: View {
    let onCreateGroup: () -> Void
    let onJoinGroup: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.spacing.xlarge) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.primaryGradient)
            
            Text("加入学习小组")
                .font(.title.bold())
            
            Text("与同学一起学习\n共享课程表和笔记")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: Theme.spacing.medium) {
                Button(action: onCreateGroup) {
                    Label("创建小组", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onJoinGroup) {
                    Label("加入小组", systemImage: "person.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StudyGroupRow: View {
    let group: StudyGroup
    
    var body: some View {
        HStack {
            // 小组图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: group.colorHex).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color(hex: group.colorHex))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                if !group.groupDescription.isEmpty {
                    Text(group.groupDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("\(group.memberCount)人")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct CreateStudyGroupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor = "#4A90E2"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("小组名称", text: $name)
                    TextField("小组描述", text: $description)
                }
                
                Section("颜色") {
                    ColorPicker("选择颜色", selection: Binding(
                        get: { Color(hex: selectedColor) },
                        set: { selectedColor = $0.toHex() ?? "#4A90E2" }
                    ))
                }
            }
            .navigationTitle("创建学习小组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        let group = StudyGroup(
                            name: name,
                            groupDescription: description,
                            colorHex: selectedColor
                        )
                        context.insert(group)
                        dismiss()
                        HapticManager.shared.success()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct JoinStudyGroupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var allGroups: [StudyGroup]
    
    @State private var inviteCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacing.xlarge) {
                Image(systemName: "qrcode")
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.primaryGradient)
                
                Text("输入邀请码")
                    .font(.title.bold())
                
                TextField("6位数字邀请码", text: $inviteCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .padding(.horizontal, 40)
                    .onChange(of: inviteCode) { _, newValue in
                        // 限制只能输入数字，最多6位
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue || filtered.count > 6 {
                            inviteCode = String(filtered.prefix(6))
                        }
                    }
                
                Text("或扫描小组二维码")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: joinGroup) {
                    Text("加入小组")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryGradient)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(inviteCode.count != 6)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("加入小组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .alert(isSuccess ? "成功加入小组" : "加入失败", isPresented: $showAlert) {
                Button("确定") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func joinGroup() {
        // 查找具有该邀请码的小组
        if let group = allGroups.first(where: { $0.inviteCode == inviteCode }) {
            // 检查是否已经在小组中（简化判断：如果已经存在就认为已加入）
            if allGroups.contains(where: { $0.id == group.id }) {
                // 增加成员数
                group.memberCount += 1
                
                isSuccess = true
                alertMessage = "成功加入「\(group.name)」小组！\n当前成员：\(group.memberCount)人"
                showAlert = true
                
                HapticManager.shared.success()
            }
        } else {
            // 未找到小组
            isSuccess = false
            alertMessage = "未找到邀请码为「\(inviteCode)」的小组\n请检查邀请码是否正确"
            showAlert = true
            
            HapticManager.shared.error()
        }
    }
}

struct StudyGroupDetailView: View {
    @Bindable var group: StudyGroup
    @Query private var courses: [CourseItem]
    @Query private var notes: [Note]
    
    var body: some View {
        List {
            // 小组信息
            Section {
                HStack {
                    Text("邀请码")
                    Spacer()
                    Text(group.inviteCode)
                        .font(.system(.title3, design: .monospaced).bold())
                    Button(action: {
                        UIPasteboard.general.string = group.inviteCode
                        HapticManager.shared.success()
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                HStack {
                    Text("成员数")
                    Spacer()
                    Text("\(group.memberCount)人")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("小组信息")
            }
            
            // 共享课程表
            Section {
                ForEach(sharedCourses) { course in
                    Text(course.courseName)
                }
                
                Button(action: {
                    // TODO: 实现共享课程功能
                    // 需要选择自己的课程并分享给小组
                }) {
                    Label("添加共享课程", systemImage: "plus.circle")
                }
                .disabled(true) // 暂未实现
            } header: {
                Text("共享课程表")
            }
            
            // 共享笔记
            Section {
                ForEach(sharedNotes) { note in
                    Text(note.title)
                }
                
                Button(action: {
                    // TODO: 实现共享笔记功能
                    // 需要选择自己的笔记并分享给小组
                }) {
                    Label("添加共享笔记", systemImage: "plus.circle")
                }
                .disabled(true) // 暂未实现
            } header: {
                Text("共享笔记")
            }
        }
        .navigationTitle(group.name)
    }
    
    private var sharedCourses: [CourseItem] {
        courses.filter { group.sharedCourses.contains($0.id) }
    }
    
    private var sharedNotes: [Note] {
        notes.filter { group.sharedNotes.contains($0.id) }
    }
}

// Color扩展
extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

