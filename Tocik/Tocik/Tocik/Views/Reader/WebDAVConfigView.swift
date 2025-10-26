//
//  WebDAVConfigView.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import SwiftUI

struct WebDAVConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webdavManager = WebDAVManager.shared
    
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("服务器信息") {
                    TextField("服务器地址", text: $serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                    TextField("用户名", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("密码", text: $password)
                }
                
                Section {
                    Text("示例服务器地址：")
                        .font(Theme.captionFont)
                        .foregroundColor(.secondary)
                    
                    Text("https://dav.jianguoyun.com/dav/")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(Theme.captionFont)
                    }
                }
                
                Section {
                    Button(action: testConnection) {
                        HStack {
                            Spacer()
                            if isConnecting {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isConnecting ? "连接中..." : "测试连接")
                            Spacer()
                        }
                    }
                    .disabled(isConnecting || serverURL.isEmpty || username.isEmpty || password.isEmpty)
                    
                    if webdavManager.isConnected {
                        Button(role: .destructive, action: disconnect) {
                            HStack {
                                Spacer()
                                Text("断开连接")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("WebDAV配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSavedCredentials()
            }
        }
    }
    
    private func loadSavedCredentials() {
        if let savedURL = UserDefaults.standard.string(forKey: "webdav_server") {
            serverURL = savedURL
        }
        if let savedUsername = UserDefaults.standard.string(forKey: "webdav_username") {
            username = savedUsername
        }
        if let savedPassword = UserDefaults.standard.string(forKey: "webdav_password") {
            password = savedPassword
        }
    }
    
    private func testConnection() {
        isConnecting = true
        errorMessage = nil
        
        Task {
            let success = await webdavManager.connect(
                serverURL: serverURL,
                username: username,
                password: password
            )
            
            await MainActor.run {
                isConnecting = false
                if success {
                    dismiss()
                } else {
                    errorMessage = "连接失败，请检查服务器地址和凭据"
                }
            }
        }
    }
    
    private func disconnect() {
        webdavManager.clearCredentials()
        serverURL = ""
        username = ""
        password = ""
    }
}

#Preview {
    WebDAVConfigView()
}

