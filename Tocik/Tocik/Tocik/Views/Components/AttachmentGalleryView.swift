//
//  AttachmentGalleryView.swift
//  Tocik
//
//  Created by AI Assistant on 2025/10/23.
//  v4.0 - 附件画廊
//

import SwiftUI
import SwiftData
import PhotosUI

struct AttachmentGalleryView: View {
    @Binding var attachments: [Attachment]
    @Environment(\.modelContext) private var context
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedAttachment: Attachment?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing.medium) {
            HStack {
                Text("附件")
                    .font(Theme.headlineFont)
                
                Spacer()
                
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .videos])
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.primaryGradient)
                }
            }
            
            if attachments.isEmpty {
                Text("暂无附件")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(attachments) { attachment in
                        AttachmentThumbnail(attachment: attachment) {
                            selectedAttachment = attachment
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .onChange(of: selectedItems) { oldValue, newValue in
            Task {
                await loadSelectedItems()
            }
        }
        .sheet(item: $selectedAttachment) { attachment in
            AttachmentDetailView(attachment: attachment)
        }
    }
    
    private func loadSelectedItems() async {
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // 确定类型
                let fileType: Attachment.FileType
                if let contentType = item.supportedContentTypes.first {
                    if contentType.conforms(to: .image) {
                        fileType = .image
                    } else if contentType.conforms(to: .video) {
                        fileType = .video
                    } else {
                        fileType = .other
                    }
                } else {
                    fileType = .other
                }
                
                let fileName = "附件_\(Date().timeIntervalSince1970)"
                let attachment = Attachment(fileName: fileName, fileType: fileType, fileData: data)
                
                // 如果是图片，生成缩略图
                if fileType == .image, let image = UIImage(data: data) {
                    attachment.thumbnailData = PerformanceOptimizer.compressImage(
                        PerformanceOptimizer.generateThumbnail(image) ?? image,
                        maxSizeKB: 50
                    )
                }
                
                context.insert(attachment)
                attachments.append(attachment)
            }
        }
        
        selectedItems = []
        HapticManager.shared.success()
    }
}

struct AttachmentThumbnail: View {
    let attachment: Attachment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if attachment.fileType == .image {
                    if let thumbnailData = attachment.thumbnailData,
                       let thumbnail = UIImage(data: thumbnailData) {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else if let image = UIImage(data: attachment.fileData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(fileTypeColor.opacity(0.2))
                        
                        VStack(spacing: 4) {
                            Image(systemName: attachment.fileType.iconName)
                                .font(.title)
                                .foregroundColor(fileTypeColor)
                            
                            Text(attachment.fileType.rawValue)
                                .font(.caption2)
                                .foregroundColor(fileTypeColor)
                        }
                    }
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private var fileTypeColor: Color {
        switch attachment.fileType {
        case .image: return .blue
        case .audio: return .purple
        case .video: return .red
        case .document: return .orange
        case .other: return .gray
        }
    }
}

struct AttachmentDetailView: View {
    let attachment: Attachment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing.large) {
                    if attachment.fileType == .image,
                       let image = UIImage(data: attachment.fileData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: attachment.fileType.iconName)
                                .font(.system(size: 80))
                                .foregroundStyle(Theme.primaryGradient)
                            
                            Text(attachment.fileName)
                                .font(.headline)
                            
                            Text(attachment.formattedFileSize)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // 分享按钮
                    ShareLink(item: attachment.fileData, preview: SharePreview(attachment.fileName)) {
                        Label("分享", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryGradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(attachment.fileName)
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

