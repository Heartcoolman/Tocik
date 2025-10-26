//
//  CourseMaterialsView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 课程资料库
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct CourseMaterialsView: View {
    @Bindable var course: CourseItem
    @Environment(\.modelContext) private var context
    
    @State private var showAddMaterial = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showDocScanner = false
    
    private var addMaterialMenu: some View {
        Menu {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Label("从相册选择", systemImage: "photo.on.rectangle")
            }
            
            Button(action: {
                showCamera = true
            }) {
                Label("拍照", systemImage: "camera")
            }
            
            Button(action: {
                showDocScanner = true
            }) {
                Label("扫描文档", systemImage: "doc.text.viewfinder")
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
    var body: some View {
        List {
            Section {
                Text("课程资料可以包含课件、教材、笔记等学习资源")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if course.materials.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "folder.fill.badge.plus")
                            .font(.system(size: 50))
                            .foregroundStyle(Theme.courseGradient)
                        
                        Text("暂无资料")
                            .font(.headline)
                        
                        Text("添加课程相关的文件和图片")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            } else {
                Section {
                    ForEach(course.materials.sorted { $0.createdDate > $1.createdDate }) { material in
                        MaterialRow(material: material)
                    }
                    .onDelete(perform: deleteMaterial)
                }
            }
        }
        .navigationTitle("课程资料")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addMaterialMenu
            }
        }
        .onChange(of: selectedItems) { oldValue, newValue in
            Task {
                await loadSelectedItems()
            }
        }
        .alert("相机功能", isPresented: $showCamera) {
            Button("确定") { }
        } message: {
            Text("拍照功能需要相机权限。您可以使用相册选择功能上传已拍摄的照片。")
        }
        .alert("文档扫描", isPresented: $showDocScanner) {
            Button("确定") { }
        } message: {
            Text("文档扫描功能需要相机权限。您可以使用相册选择功能上传已扫描的文档。")
        }
    }
    
    private func loadSelectedItems() async {
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // 确定文件类型
                let fileType: Attachment.FileType
                if let contentType = item.supportedContentTypes.first {
                    if contentType.conforms(to: .image) {
                        fileType = .image
                    } else if contentType.conforms(to: .pdf) {
                        fileType = .document
                    } else {
                        fileType = .other
                    }
                } else {
                    fileType = .other
                }
                
                let fileName = "资料_\(Date().timeIntervalSince1970)"
                let attachment = Attachment(fileName: fileName, fileType: fileType, fileData: data)
                
                context.insert(attachment)
                course.materials.append(attachment)
            }
        }
        
        selectedItems = []
        HapticManager.shared.success()
    }
    
    private func deleteMaterial(at offsets: IndexSet) {
        let sortedMaterials = course.materials.sorted { $0.createdDate > $1.createdDate }
        for index in offsets {
            if let material = sortedMaterials[safe: index] {
                course.materials.removeAll { $0.id == material.id }
                context.delete(material)
            }
        }
        HapticManager.shared.medium()
    }
}

struct MaterialRow: View {
    let material: Attachment
    @State private var showPreview = false
    
    var body: some View {
        Button(action: { showPreview = true }) {
            HStack(spacing: 12) {
                // 文件类型图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fileTypeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: material.fileType.iconName)
                        .font(.title3)
                        .foregroundColor(fileTypeColor)
                }
                
                // 文件信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(material.fileName)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    HStack {
                        Text(material.fileType.rawValue)
                            .font(.caption)
                        
                        Text("·")
                            .font(.caption)
                        
                        Text(material.formattedFileSize)
                            .font(.caption)
                        
                        Text("·")
                            .font(.caption)
                        
                        Text(formatDate(material.createdDate))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPreview) {
            MaterialPreviewView(material: material)
        }
    }
    
    private var fileTypeColor: Color {
        switch material.fileType {
        case .image: return .blue
        case .audio: return .purple
        case .video: return .red
        case .document: return .orange
        case .other: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct MaterialPreviewView: View {
    let material: Attachment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if material.fileType == .image,
                   let uiImage = UIImage(data: material.fileData) {
                    ScrollView([.horizontal, .vertical]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: material.fileType.iconName)
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text(material.fileName)
                            .font(.headline)
                        
                        Text(material.formattedFileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ShareLink(item: material.fileData, preview: SharePreview(material.fileName)) {
                            Label("分享", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .padding()
                                .background(Theme.primaryGradient)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .navigationTitle(material.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 数组安全下标扩展
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

