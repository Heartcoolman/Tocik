# Tocik 代码质量指南

## 概述

本指南提供了 Tocik 项目的代码质量标准和最佳实践。

## 代码规范

### 1. 日志记录

**✅ 正确做法**:
```swift
AppLogger.app.info("应用启动")
AppLogger.network.debug("API请求: \(endpoint)")
AppLogger.database.error("数据加载失败: \(error)")
```

**❌ 错误做法**:
```swift
print("应用启动")  // 不要使用print
```

### 2. 异步任务和内存管理

**✅ 正确做法**:
```swift
Task { [weak self] in
    guard let self = self else { return }
    await self.doSomething()
}
```

**❌ 错误做法**:
```swift
Task {
    await doSomething()  // 可能导致内存泄漏
}
```

### 3. API密钥管理

**✅ 正确做法**:
```swift
// 在 Config.xcconfig 中配置
DEEPSEEK_API_KEY = your-key-here

// 在代码中读取
let apiKey = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY")
```

**❌ 错误做法**:
```swift
let apiKey = "sk-xxx..."  // 不要硬编码
```

### 4. 数据库操作

**✅ 正确做法**:
```swift
AppLogger.logDatabaseOperation("插入用户数据", duration: duration)
try context.save()
```

**❌ 错误做法**:
```swift
try context.save()  // 应该记录日志
```

### 5. 错误处理

**✅ 正确做法**:
```swift
do {
    try riskyOperation()
} catch {
    AppLogger.logError(category: .app, message: "操作失败", error: error)
}
```

**❌ 错误做法**:
```swift
try! riskyOperation()  // 不要使用 try!
let value = optional!  // 避免强制解包
```

## SwiftLint 集成

### 安装 SwiftLint

```bash
# 使用 Homebrew
brew install swiftlint

# 或使用 CocoaPods
pod 'SwiftLint'
```

### 运行 SwiftLint

```bash
# 在项目根目录运行
swiftlint

# 自动修复可修复的问题
swiftlint --fix

# 仅检查特定文件
swiftlint lint --path Tocik/Tocik/Tocik/Views/
```

### Xcode 集成

在 Xcode 的 Build Phases 中添加 Run Script:

```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

## 代码审查清单

在提交代码前，请确保：

- [ ] 没有使用 `print()` 进行日志记录
- [ ] 所有 `Task` 闭包都使用了 `[weak self]`
- [ ] 没有硬编码的 API 密钥或敏感信息
- [ ] 重要的数据库操作都记录了日志
- [ ] 没有使用 `try!` 或 `!` 强制解包
- [ ] 代码通过了 SwiftLint 检查
- [ ] 添加了必要的注释说明复杂逻辑

## 性能优化建议

### 1. 避免过度查询

**✅ 使用 ViewModel 缓存**:
```swift
@StateObject private var viewModel = StudyDataViewModel()
```

**❌ 多个 @Query**:
```swift
@Query private var todos: [TodoItem]
@Query private var habits: [Habit]
@Query private var sessions: [PomodoroSession]
```

### 2. 使用异步操作

**✅ 正确做法**:
```swift
Task.detached {
    let result = await heavyComputation()
    await MainActor.run {
        self.result = result
    }
}
```

### 3. 合理使用缓存

利用 `AnalysisCache` 缓存计算结果：
```swift
if let cached = AnalysisCache.shared.getCachedStudyPattern(userId: userId) {
    return cached
}
```

## 测试要求

### 单元测试

为核心业务逻辑编写单元测试：
- 数据模型
- 工具类方法
- 算法和计算逻辑

### 性能测试

使用 Instruments 监控：
- 内存使用
- CPU占用
- 数据库查询次数

## 文档要求

每个新增的类和公共方法都应该包含：
- 功能说明
- 参数说明
- 返回值说明
- 使用示例（如有必要）

示例：
```swift
/// 分析用户的学习模式
/// - Parameters:
///   - sessions: 番茄钟会话列表
///   - todos: 待办事项列表
/// - Returns: 学习模式分析结果
static func analyzeStudyPattern(
    sessions: [PomodoroSession],
    todos: [TodoItem]
) -> StudyPattern {
    // 实现...
}
```

## 持续改进

代码质量是一个持续改进的过程：
1. 定期运行 SwiftLint
2. 进行代码审查
3. 重构重复代码
4. 优化性能瓶颈
5. 更新文档

## 参考资源

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

