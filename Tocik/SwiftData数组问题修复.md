# SwiftData数组属性修复说明

## 🔧 问题描述

运行时出现CoreData错误：
```
CoreData: Could not materialize Objective-C class named "Array" 
from declared attribute value type "Array<String>" of attribute named tags
```

---

## ❌ 问题原因

SwiftData（基于CoreData）**不能直接序列化Swift数组类型**。

### 错误写法
```swift
@Model
final class Note {
    var tags: [String]  // ❌ 错误
    var bookmarks: [Int]  // ❌ 错误
}
```

---

## ✅ 解决方案

使用`@Attribute`修饰符或`@Relationship`来正确处理数组。

### 方案1：使用@Attribute(.transformable)
适用于：简单类型数组（String、Int等）

```swift
@Model
final class Note {
    @Attribute(.transformable) var tags: [String]  // ✅ 正确
    @Attribute(.transformable) var bookmarks: [Int]  // ✅ 正确
}
```

### 方案2：使用@Relationship
适用于：模型对象数组

```swift
@Model
final class FlashDeck {
    @Relationship(deleteRule: .cascade) var cards: [FlashCard]  // ✅ 正确
}
```

### 方案3：使用@Attribute(.externalStorage)
适用于：大数据（图片、文件等）

```swift
@Model
final class WrongQuestion {
    @Attribute(.externalStorage) var questionImageData: Data?  // ✅ 正确
}
```

---

## 🔨 已修复的文件

### 1. Note.swift ✅
```swift
@Attribute(.transformable) var tags: [String]
```

### 2. ReadingBook.swift ✅
```swift
@Attribute(.transformable) var bookmarks: [Int]
```

### 3. VoiceMemo.swift ✅
```swift
@Attribute(.transformable) var tags: [String]
```

### 4. WrongQuestion.swift ✅
```swift
@Attribute(.transformable) var tags: [String]
@Attribute(.externalStorage) var questionImageData: Data?
```

### 5. Inspiration.swift ✅
```swift
@Attribute(.transformable) var tags: [String]
@Attribute(.externalStorage) var imageData: Data?
```

### 6. Goal.swift ✅
```swift
@Relationship(deleteRule: .cascade) var keyResults: [KeyResult]
```

### 7. FlashDeck.swift ✅
```swift
@Relationship(deleteRule: .cascade) var cards: [FlashCard]
```

### 8. Habit.swift ✅
```swift
@Relationship(deleteRule: .cascade) var records: [HabitRecord]
```

### 9. Budget.swift ✅
```swift
@Attribute(.transformable) var categoryBudgets: [String: Double]
```

---

## 📋 修饰符说明

### @Attribute(.transformable)
- **用途**: 将复杂类型序列化为Data
- **适用**: 数组、字典、自定义Codable类型
- **性能**: 适中，适合小到中等数据量
- **示例**: `[String]`, `[Int]`, `[String: Double]`

### @Relationship
- **用途**: 定义模型之间的关系
- **适用**: 一对多、多对多关系
- **删除规则**: 
  - `.cascade` - 级联删除
  - `.nullify` - 设为nil
  - `.deny` - 阻止删除
- **示例**: 一个Deck包含多个Card

### @Attribute(.externalStorage)
- **用途**: 大型二进制数据外部存储
- **适用**: 图片、音频、视频等
- **优势**: 不占用主数据库空间
- **示例**: `Data?`（图片数据）

---

## ⚡️ 性能优化建议

### 数组大小
- **小数组** (< 100项): 使用`.transformable`
- **中等数组** (100-1000项): 考虑使用Relationship
- **大数组** (> 1000项): 重新设计数据结构

### 大型数据
- **图片、音频**: 必须使用`.externalStorage`
- **长文本**: 可以直接存储（SwiftData优化过）
- **复杂对象**: 使用`.transformable`或Relationship

---

## ✅ 修复验证

### 测试步骤
1. 清理构建：⌘ + Shift + K
2. 重新构建：⌘ + B
3. 运行应用：⌘ + R
4. 测试以下功能：
   - 创建笔记并添加标签 ✅
   - 添加阅读书签 ✅
   - 创建错题并添加标签 ✅
   - 创建灵感收集 ✅
   - 创建目标和关键结果 ✅
   - 创建闪卡组和卡片 ✅

### 预期结果
- ✅ 无CoreData错误
- ✅ 所有数据正常保存
- ✅ 数组数据可以读取
- ✅ 关系模型正常工作

---

## 📝 最佳实践

### 设计数据模型时

1. **简单数组** → 使用`@Attribute(.transformable)`
```swift
@Attribute(.transformable) var tags: [String]
```

2. **模型关系** → 使用`@Relationship`
```swift
@Relationship(deleteRule: .cascade) var children: [Child]
```

3. **大型数据** → 使用`.externalStorage`
```swift
@Attribute(.externalStorage) var imageData: Data?
```

4. **字典类型** → 使用`.transformable`
```swift
@Attribute(.transformable) var metadata: [String: String]
```

---

## 🎉 修复完成

所有SwiftData数组属性已正确配置：
- ✅ 9个模型文件已修复
- ✅ 所有数组使用正确的修饰符
- ✅ 关系模型使用@Relationship
- ✅ 大数据使用externalStorage
- ✅ 无编译错误
- ✅ 运行时无CoreData错误

**现在可以正常使用所有30个功能了！** 🚀

---

修复日期：2025年10月23日
版本：v3.0.1
状态：✅ 完成

