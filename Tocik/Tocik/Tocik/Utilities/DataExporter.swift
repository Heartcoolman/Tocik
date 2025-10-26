//
//  DataExporter.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//

import Foundation
import SwiftUI

struct DataExporter {
    static func exportToJSON() -> URL? {
        // 创建导出数据结构
        let exportData: [String: Any] = [
            "version": "1.0",
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appName": "Tocik"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let fileName = "Tocik_Export_\(Date().formatted("yyyyMMdd_HHmmss")).json"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("导出失败: \(error)")
            return nil
        }
    }
    
    static func shareFile(_ url: URL) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            rootVC.present(activityVC, animated: true)
        }
    }
}

