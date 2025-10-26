//
//  TocikApp.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  Updated: v4.0 - 添加所有新模型 + 启用新界面
//

import SwiftUI
import SwiftData

@main
struct TocikApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            StudyContentView()  // v5.0: 全新学习专属界面
                .modelContainer(appCoordinator.container)
                .environmentObject(appCoordinator.notificationManager)
                .environmentObject(appCoordinator)
                .task {
                    await appCoordinator.initialize()
                }
        }
    }
}
