//
//  DataManagementView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI
import SwiftData

struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingExportSuccess = false
    @State private var showingClearAlert = false
    @State private var showDeveloperSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("数据备份") {
                    Button(action: exportData) {
                        Label("导出所有数据", systemImage: "square.and.arrow.up")
                    }
                    .disabled(true)
                    
                    Button(action: {}) {
                        Label("导入数据", systemImage: "square.and.arrow.down")
                    }
                    .disabled(true)
                }
                
                Section {
                    Text("注意：导出功能在模拟器中可能无法正常工作，请在真机上测试")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("WebDAV备份") {
                    Toggle("自动备份到WebDAV", isOn: .constant(false))
                    
                    Button(action: {}) {
                        Label("立即备份", systemImage: "icloud.and.arrow.up")
                    }
                }
                
                Section("数据统计") {
                    HStack {
                        Text("应用版本")
                        Spacer()
                        Text("5.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("数据占用")
                        Spacer()
                        Text("计算中...")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("高级") {
                    NavigationLink {
                        DeveloperSettingsView()
                    } label: {
                        Label("开发者设置", systemImage: "hammer.fill")
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showingClearAlert = true }) {
                        Label("清空所有数据", systemImage: "trash")
                    }
                } header: {
                    Text("危险操作")
                } footer: {
                    Text("此操作将删除所有数据且无法恢复，请谨慎操作")
                }
            }
            .navigationTitle("数据管理")
            .alert("导出成功", isPresented: $showingExportSuccess) {
                Button("OK", role: .cancel) { }
            }
            .alert("确认清空数据？", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) { }
                Button("确认", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作将删除所有数据且无法恢复")
            }
        }
    }
    
    private func exportData() {
        if let url = DataExporter.exportToJSON() {
            DataExporter.shareFile(url)
            showingExportSuccess = true
        }
    }
    
    private func clearAllData() {
        // 清空数据的实现
        try? modelContext.save()
    }
}

#Preview {
    DataManagementView()
}

