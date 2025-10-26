//
//  WebDAVManager.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import Security
import Combine

@MainActor
class WebDAVManager: ObservableObject {
    static let shared = WebDAVManager()
    
    @Published var isConnected = false
    @Published var currentPath = "/"
    @Published var files: [WebDAVFile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var serverURL: String?
    private var username: String?
    private var password: String?
    
    struct WebDAVFile: Identifiable {
        let id = UUID()
        let name: String
        let path: String
        let isDirectory: Bool
        let size: Int64?
        let modifiedDate: Date?
    }
    
    private init() {
        loadCredentials()
    }
    
    // MARK: - 凭据管理（使用UserDefaults，生产环境应使用Keychain）
    func saveCredentials(serverURL: String, username: String, password: String) {
        self.serverURL = serverURL
        self.username = username
        self.password = password
        
        UserDefaults.standard.set(serverURL, forKey: "webdav_server")
        UserDefaults.standard.set(username, forKey: "webdav_username")
        
        // 在生产环境中应该使用Keychain存储密码
        UserDefaults.standard.set(password, forKey: "webdav_password")
    }
    
    func loadCredentials() {
        serverURL = UserDefaults.standard.string(forKey: "webdav_server")
        username = UserDefaults.standard.string(forKey: "webdav_username")
        password = UserDefaults.standard.string(forKey: "webdav_password")
        
        isConnected = serverURL != nil && username != nil && password != nil
    }
    
    func clearCredentials() {
        serverURL = nil
        username = nil
        password = nil
        isConnected = false
        
        UserDefaults.standard.removeObject(forKey: "webdav_server")
        UserDefaults.standard.removeObject(forKey: "webdav_username")
        UserDefaults.standard.removeObject(forKey: "webdav_password")
    }
    
    // MARK: - WebDAV操作
    func connect(serverURL: String, username: String, password: String) async -> Bool {
        saveCredentials(serverURL: serverURL, username: username, password: password)
        
        // 测试连接
        let success = await listFiles(path: "/")
        if success {
            isConnected = true
        } else {
            clearCredentials()
        }
        return success
    }
    
    @discardableResult
    func listFiles(path: String) async -> Bool {
        guard let serverURL = serverURL,
              let username = username,
              let password = password else {
            errorMessage = "未配置WebDAV服务器"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        currentPath = path
        
        let fullURL = serverURL.appending(path)
        guard let url = URL(string: fullURL) else {
            errorMessage = "无效的URL"
            isLoading = false
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        // 添加Basic认证
        let credentials = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        // PROPFIND请求体
        let propfindBody = """
        <?xml version="1.0" encoding="utf-8" ?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:displayname/>
                <D:getcontentlength/>
                <D:getlastmodified/>
                <D:resourcetype/>
            </D:prop>
        </D:propfind>
        """
        request.httpBody = propfindBody.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "无效的响应"
                isLoading = false
                return false
            }
            
            if httpResponse.statusCode == 207 {
                // 解析WebDAV响应
                files = parseWebDAVResponse(data: data, basePath: path)
                isLoading = false
                return true
            } else if httpResponse.statusCode == 401 {
                errorMessage = "认证失败，请检查用户名和密码"
                isLoading = false
                return false
            } else {
                errorMessage = "连接失败: HTTP \(httpResponse.statusCode)"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "连接失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func downloadFile(file: WebDAVFile) async -> String? {
        guard let serverURL = serverURL,
              let username = username,
              let password = password else {
            return nil
        }
        
        let fullURL = serverURL.appending(file.path)
        guard let url = URL(string: fullURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let credentials = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let content = String(data: data, encoding: .utf8) {
                return content
            }
            return nil
        } catch {
            print("下载文件失败: \(error)")
            return nil
        }
    }
    
    // 简单的WebDAV XML解析（实际应用中应使用XMLParser）
    private func parseWebDAVResponse(data: Data, basePath: String) -> [WebDAVFile] {
        guard let xmlString = String(data: data, encoding: .utf8) else { return [] }
        
        var files: [WebDAVFile] = []
        
        // 这是一个简化的解析，实际应该使用XMLParser
        let lines = xmlString.components(separatedBy: "<D:response>")
        
        for line in lines.dropFirst() {
            if let hrefRange = line.range(of: "<D:href>"),
               let hrefEndRange = line.range(of: "</D:href>") {
                var path = String(line[hrefRange.upperBound..<hrefEndRange.lowerBound])
                
                // 解码URL编码
                path = path.removingPercentEncoding ?? path
                
                // 跳过当前目录本身
                if path.hasSuffix(basePath) && path != basePath {
                    continue
                }
                
                let isDirectory = line.contains("<D:collection/>")
                let name = URL(fileURLWithPath: path).lastPathComponent
                
                // 提取文件大小
                var size: Int64?
                if let sizeRange = line.range(of: "<D:getcontentlength>"),
                   let sizeEndRange = line.range(of: "</D:getcontentlength>") {
                    let sizeString = String(line[sizeRange.upperBound..<sizeEndRange.lowerBound])
                    size = Int64(sizeString)
                }
                
                if !name.isEmpty && path != basePath {
                    files.append(WebDAVFile(
                        name: name,
                        path: path,
                        isDirectory: isDirectory,
                        size: size,
                        modifiedDate: nil
                    ))
                }
            }
        }
        
        return files
    }
}

