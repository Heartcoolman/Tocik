//
//  AddWrongQuestionView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddWrongQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allSubjects: [Subject] // v5.0: 获取所有科目
    
    @State private var subject = ""
    @State private var selectedSubject: Subject? // v5.0: 选中的科目对象
    @State private var analysis = ""
    @State private var note = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    let subjects = ["数学", "物理", "化学", "英语", "语文", "生物", "历史", "地理"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("科目") {
                    // v5.0: 优先显示已创建的科目
                    if !allSubjects.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(allSubjects) { subj in
                                Button(action: {
                                    subject = subj.name
                                    selectedSubject = subj
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: subj.icon)
                                            .font(.caption2)
                                        Text(subj.name)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSubject?.id == subj.id ? Color(hex: subj.colorHex) : Color(.systemGray6))
                                    .foregroundColor(selectedSubject?.id == subj.id ? .white : .primary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // 快速选择或自定义
                    TextField("或输入科目名称", text: $subject)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach(subjects, id: \.self) { subj in
                            Button(subj) {
                                subject = subj
                                selectedSubject = nil // 使用快速选择时清除科目对象
                            }
                            .font(.caption)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(subject == subj && selectedSubject == nil ? Theme.primaryColor : Color(.systemGray6))
                            .foregroundColor(subject == subj && selectedSubject == nil ? .white : .primary)
                            .cornerRadius(8)
                        }
                    }
                }
                
                Section("题目图片") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                        
                        Button("重新选择") {
                            showingImagePicker = true
                        }
                    } else {
                        Button(action: { showingImagePicker = true }) {
                            Label("拍照或选择图片", systemImage: "camera.fill")
                        }
                    }
                }
                
                Section("解析") {
                    TextEditor(text: $analysis)
                        .frame(minHeight: 100)
                }
                
                Section("笔记") {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("添加错题")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveQuestion()
                    }
                    .disabled(subject.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveQuestion() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let question = WrongQuestion(
            subject: subject,
            questionImageData: imageData,
            analysis: analysis,
            note: note,
            subjectId: selectedSubject?.id // v5.0: 保存科目关联
        )
        
        modelContext.insert(question)
        
        // v5.0: 如果关联了科目，更新科目统计
        if let subject = selectedSubject {
            subject.updateStats(wrongQuestions: 1)
        }
        
        try? modelContext.save()
        HapticManager.shared.success()
        dismiss()
    }
}

// 简单的ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

#Preview {
    AddWrongQuestionView()
        .modelContainer(for: WrongQuestion.self, inMemory: true)
}

