<!-- 68ae69e7-97b2-49d0-89a7-508324f52061 9376cb92-fc29-4837-bba0-417944dcb638 -->
# 卡片过渡动画重构 - matchedGeometryEffect

## 目标效果

类似 iOS 照片 App 的动画：
- 点击卡片：从卡片当前位置放大到全屏
- 返回：从全屏缩小回到卡片原位置
- 动画流畅，保持空间连续性

## 技术方案

使用 `@Namespace` 和 `.matchedGeometryEffect()` 实现共享元素过渡动画。

---

## 实施步骤

### 步骤1：在 iPadEnhancedLayout 中创建 Namespace

**文件**: `EnhancedContentView.swift` (第 28-103 行)

**添加**：
```swift
struct iPadEnhancedLayout: View {
    @State private var selectedCategory: String? = "dashboard"
    @State private var selectedTool: ToolItem?
    @State private var showIntelligentPanel = false
    @State private var previousCategory: String? = "dashboard"
    @Namespace private var cardAnimation  // ← 添加这个
```

### 步骤2：修改 CategoryGridView 添加 matchedGeometryEffect

**文件**: `EnhancedContentView.swift` (第 720 行左右)

**当前**：
```swift
struct CategoryGridView: View {
    let category: String
    @Binding var selectedTool: ToolItem?
    @State private var isAppeared = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
```

**改为**：
```swift
struct CategoryGridView: View {
    let category: String
    @Binding var selectedTool: ToolItem?
    var namespace: Namespace.ID  // ← 添加 namespace 参数
    @State private var isAppeared = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
```

**在卡片上应用**：
```swift
ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
    Button(action: {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            selectedTool = tool
        }
    }) {
        ModernToolCard(tool: tool)
            .matchedGeometryEffect(
                id: tool.id,           // ← 使用工具的唯一 ID
                in: namespace,          // ← 使用传入的 namespace
                properties: .frame,     // ← 只匹配 frame，不包括内容
                isSource: selectedTool?.id != tool.id  // ← 关键：未选中时作为源
            )
    }
    .buttonStyle(CardButtonStyle())
    // ... 动画代码
}
```

### 步骤3：修改 mainContentView 传递 namespace

**文件**: `EnhancedContentView.swift` (第 105-116 行)

**当前**：
```swift
@ViewBuilder
private func mainContentView(for category: String) -> some View {
    switch category {
    case "dashboard":
        DashboardView()
    case "core", "study", "info", "content", "utility", "life":
        CategoryGridView(category: category, selectedTool: $selectedTool)
    case "intelligent":
        IntelligentFeaturesHub()
    default:
        DashboardView()
    }
}
```

**改为**：
```swift
@ViewBuilder
private func mainContentView(for category: String) -> some View {
    switch category {
    case "dashboard":
        DashboardView()
    case "core", "study", "info", "content", "utility", "life":
        CategoryGridView(
            category: category, 
            selectedTool: $selectedTool,
            namespace: cardAnimation  // ← 传递 namespace
        )
    case "intelligent":
        IntelligentFeaturesHub()
    default:
        DashboardView()
    }
}
```

### 步骤4：为工具详情页添加 matchedGeometryEffect

**文件**: `EnhancedContentView.swift` (第 40-69 行)

**当前**：
```swift
if let tool = selectedTool {
    destinationView(for: tool)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .toolbar { ... }
}
```

**改为**：
```swift
if let tool = selectedTool {
    ZStack {
        // 背景层（避免内容闪烁）
        Color.clear
            .matchedGeometryEffect(
                id: tool.id,
                in: cardAnimation,
                properties: .frame,
                isSource: false  // ← 作为目标
            )
        
        // 实际内容
        destinationView(for: tool)
    }
    .toolbar { ... }
}
```

**或者更优雅的方式**：
```swift
if let tool = selectedTool {
    destinationView(for: tool)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.clear
                .matchedGeometryEffect(
                    id: tool.id,
                    in: cardAnimation,
                    properties: .frame,
                    isSource: false
                )
        )
        .toolbar { ... }
}
```

### 步骤5：优化动画参数

**移除原有的 transition**：
```swift
// 删除这些
.transition(.scale(scale: 0.9).combined(with: .opacity))
```

**使用弹簧动画**：
```swift
.animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTool)
```

### 步骤6：处理背景淡入淡出

为了更好的效果，可以添加背景遮罩：

```swift
NavigationStack {
    ZStack {
        if let tool = selectedTool {
            // 背景遮罩（可选）
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            destinationView(for: tool)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemBackground))
                        .matchedGeometryEffect(
                            id: tool.id,
                            in: cardAnimation,
                            properties: .frame,
                            isSource: false
                        )
                )
                .toolbar { ... }
        } else {
            mainContentView(for: selectedCategory ?? "dashboard")
                .toolbar { ... }
        }
    }
}
```

---

## 关键技术点

### 1. matchedGeometryEffect 参数说明
```swift
.matchedGeometryEffect(
    id: "unique-id",        // 唯一标识符，源和目标必须相同
    in: namespace,          // 命名空间，在同一个 View 层级中共享
    properties: .frame,     // 匹配属性（.frame, .position, .size）
    anchor: .center,        // 锚点（可选）
    isSource: Bool          // true=源，false=目标
)
```

### 2. 动画时序
- 点击卡片：`isSource: true` → `isSource: false`
- 卡片从当前位置/大小 → 全屏位置/大小
- 内容同步淡入/淡出

### 3. 性能优化
- 只使用 `.frame` 属性匹配，避免匹配内容导致的性能问题
- 使用 `Color.clear` 或背景作为匹配层
- 实际内容在上层渲染

---

## 潜在问题和解决方案

### 问题1：卡片内容闪烁
**原因**：内容在动画过程中重新渲染
**解决**：
```swift
// 使用两层结构
ZStack {
    Color.clear.matchedGeometryEffect(...)  // 动画层
    ActualContent()                         // 内容层
}
```

### 问题2：返回动画不流畅
**原因**：目标卡片已被回收
**解决**：
```swift
// 保持 isSource 状态正确
.matchedGeometryEffect(
    id: tool.id,
    in: namespace,
    properties: .frame,
    isSource: selectedTool?.id != tool.id  // 动态判断
)
```

### 问题3：多个卡片同时动画
**原因**：ID 冲突
**解决**：
```swift
// 确保每个工具 ID 唯一
id: tool.id  // 使用工具的唯一标识符
```

---

## 测试要点

- [ ] 从不同分类的卡片打开工具
- [ ] 返回动画流畅
- [ ] 快速连续点击不会崩溃
- [ ] 横竖屏切换正常
- [ ] 不同大小的卡片都能正确动画
- [ ] 动画期间不会有闪烁
- [ ] 性能良好，60fps

---

## 预期效果

### 当前效果
```
卡片 → [缩放淡入] → 全屏
```

### 重构后效果
```
卡片(位置A, 大小S) → [精确变形] → 全屏(位置B, 大小L)
  ↓ 流畅的空间连续动画
  ↓ 卡片从原位置"飞"到全屏
  ↓ 类似 iOS 照片 App
```

### 用户体验提升
- ✨ 空间连续性：用户能清楚看到内容从哪里来
- ✨ 流畅自然：动画遵循物理规律
- ✨ 高级感：媲美原生 iOS App
- ✨ 返回直观：准确缩回到原位置

---

## 代码结构总结

```
iPadEnhancedLayout
├─ @Namespace var cardAnimation           ← 创建命名空间
├─ CategoryGridView(namespace: cardAnimation)  ← 传递给网格
│   └─ ModernToolCard
│       └─ .matchedGeometryEffect(isSource: true)  ← 源卡片
└─ destinationView(for: tool)
    └─ .matchedGeometryEffect(isSource: false)    ← 目标视图
```


### To-dos

- [ ] 在 iPadEnhancedLayout 中添加 @Namespace
- [ ] 修改 CategoryGridView 添加 namespace 参数和 matchedGeometryEffect
- [ ] 修改 mainContentView 传递 namespace
- [ ] 为工具详情页添加 matchedGeometryEffect
- [ ] 优化动画参数和移除旧的 transition
- [ ] 测试各种场景的动画效果