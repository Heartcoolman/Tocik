# AI 助手模块说明

## 📁 文件结构

```
Views/AI/
├── AIAssistantView.swift       # AI 助手主界面（本地算法）
└── DeepSeekChatView.swift      # DeepSeek 对话界面（云端AI）
```

## 🧠 双智能体架构

Tocik 采用**本地算法 + 云端AI**的双智能体架构：

### 1. 本地智能分析（AIAssistantView）

**无需网络，即时响应**

- ✅ **SmartAnalyzer** - 学习模式识别
- ✅ **PredictionEngine** - 趋势预测
- ✅ **AnomalyDetector** - 异常检测
- ✅ **SuggestionEngine** - 智能建议
- ✅ **AutoLinkManager** - 自动关联

**特点**：
- 快速响应（毫秒级）
- 无需网络
- 完全免费
- 隐私安全

### 2. DeepSeek 云端AI（DeepSeekChatView）

**深度理解，个性化对话**

- ✅ 自然语言对话
- ✅ 深度数据分析
- ✅ 个性化建议
- ✅ 学习计划制定
- ✅ 问题诊断

**特点**：
- 理解复杂问题
- 个性化建议
- 持续对话
- 专业分析

## 🔄 使用场景

### 使用本地算法（AIAssistantView）
适合：
- 日常数据查看
- 快速获取建议
- 离线使用
- 基础分析

### 使用 DeepSeek AI（DeepSeekChatView）
适合：
- 深度问题咨询
- 制定学习计划
- 诊断复杂问题
- 需要详细解释

## 🚀 快速开始

### 本地算法
```swift
// 自动分析，无需配置
AIAssistantView()
```

### DeepSeek AI
```swift
// API Key 已内置，直接使用
DeepSeekChatView()
```

## 💡 最佳实践

### 1. 互补使用
- 日常使用本地算法
- 遇到问题咨询 DeepSeek
- 定期深度分析

### 2. 数据准备
- 保持数据完整
- 定期更新记录
- 准确标记信息

### 3. 问题提问
- 具体描述问题
- 提供背景信息
- 说明期望目标

## 🔧 技术实现

### 本地算法引擎

**SmartAnalyzer.swift**
```swift
// 学习模式分析
SmartAnalyzer.analyzeStudyPattern(
    pomodoroSessions: sessions,
    todos: todos,
    habits: habits
)
```

**PredictionEngine.swift**
```swift
// 趋势预测
PredictionEngine.predictPomodoros(
    sessions: recentSessions,
    days: 7
)
```

### DeepSeek API 集成

**DeepSeekManager.swift**
```swift
// 内置 API Key
private let apiKey = "sk-..."

// 专业提示词
private let systemPrompt = """
你是 Tocik 学习助手，一个专业的学习数据分析和个性化建议智能体。
...
"""

// 智能对话
await DeepSeekManager.shared.chat(
    userMessage: "如何提高学习效率？"
)
```

## 📊 性能对比

| 特性 | 本地算法 | DeepSeek AI |
|------|---------|------------|
| 响应速度 | ⚡️ 毫秒级 | 🔄 2-4秒 |
| 网络需求 | ✅ 无需 | ❌ 需要 |
| 分析深度 | 📊 基础 | 🧠 深度 |
| 个性化 | 🤖 规则 | 💡 理解 |
| 对话能力 | ❌ 无 | ✅ 强大 |
| 成本 | 💰 免费 | 💰 免费* |

*已内置 API Key，用户无需付费

## 🎯 开发指南

### 添加新的本地算法

1. 在 `Utilities/` 创建算法文件
2. 在 `AIAssistantView` 中调用
3. 更新 UI 展示结果

### 优化 DeepSeek 提示词

1. 编辑 `DeepSeekManager.swift` 中的 `systemPrompt`
2. 测试不同场景
3. 调整回答格式

### 扩展分析功能

```swift
// 添加新的分析方法
extension DeepSeekManager {
    func analyzeCustomData(...) async -> String? {
        let userMessage = """
        自定义分析请求
        """
        return await chat(userMessage: userMessage)
    }
}
```

## 🔐 安全说明

- ✅ API Key 内置在应用中
- ✅ 不收集用户个人信息
- ✅ 对话历史仅本地存储
- ✅ 可随时清空数据

## 📝 更新日志

### v1.0.0 (2025-10-23)
- ✅ 实现双智能体架构
- ✅ 集成 DeepSeek API
- ✅ 内置 API Key
- ✅ 专业提示词设计
- ✅ 现代化对话界面

---

享受智能化学习体验！🚀

