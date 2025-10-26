//
//  ToolItem.swift
//  Tocik
//
//  Created by Tocik Team on 2025/10/23.
//  统一的工具项模型
//

import SwiftUI

struct ToolItem: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ToolItem, rhs: ToolItem) -> Bool {
        lhs.id == rhs.id
    }
}

