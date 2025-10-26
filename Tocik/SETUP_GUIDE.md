# Tocik 项目设置指南

## Xcode配置步骤

### 1. 打开项目
```bash
cd /Users/macchuzu/Documents/Tocik
open Tocik.xcodeproj
```

### 2. 配置签名

1. 选择项目导航器中的 **Tocik** 项目
2. 选择 **TARGETS** → **Tocik**
3. 选择 **Signing & Capabilities** 标签
4. 在 **Team** 下拉菜单中选择您的开发团队
5. 确保 **Automatically manage signing** 已勾选

### 3. 添加Capabilities

在 **Signing & Capabilities** 标签中，点击 **+ Capability** 按钮，添加以下能力：

#### WeatherKit (必需)
1. 搜索并添加 **WeatherKit**
2. ⚠️ **注意**: WeatherKit需要付费Apple Developer账号

#### Background Modes (可选，用于音频播放)
1. 搜索并添加 **Background Modes**
2. 勾选 **Audio, AirPlay, and Picture in Picture**

### 4. 配置Info权限

在Xcode的Info标签中添加权限描述：

1. 选择 **TARGETS** → **Tocik**
2. 选择 **Info** 标签
3. 在 **Custom iOS Target Properties** 部分，点击 **+** 添加：
   - **Key**: Privacy - Location When In Use Usage Description
   - **Type**: String
   - **Value**: 需要获取您的位置信息以提供天气预报服务

### 5. 配置Bundle Identifier

1. 在 **General** 标签下
2. 修改 **Bundle Identifier** 为您的唯一标识符
   - 建议格式: `com.yourname.Tocik`

### 6. 配置最低部署目标

1. 在 **General** 标签下
2. 确认 **Minimum Deployments** 设置为 **iOS 17.0**

### 7. WeatherKit Developer配置

#### 在Apple Developer网站配置：

1. 访问 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers**
4. 找到您的App ID（如果没有则创建新的）
5. 编辑App ID，勾选 **WeatherKit**
6. 保存更改

#### 在Xcode中验证：

1. 返回Xcode
2. **Signing & Capabilities** → **WeatherKit**
3. 如果显示红色错误，点击 **Try Again** 或重新登录Apple账号

### 8. 构建项目

1. 选择模拟器或真机设备
2. 按 **⌘ + B** 构建项目
3. 解决任何构建错误（通常与签名相关）

### 9. 运行应用

1. 按 **⌘ + R** 运行应用
2. 首次运行时会请求通知权限
3. 使用天气功能时会请求位置权限

## 常见问题

### Q: WeatherKit显示错误
**A**: 确保您：
1. 使用付费Apple Developer账号
2. 在开发者网站启用了WeatherKit
3. Bundle Identifier与App ID匹配
4. 已在Xcode中登录正确的Apple ID

### Q: 位置权限请求未显示
**A**: 
1. 检查Info.plist中是否包含位置权限描述
2. 在模拟器中：Settings → Privacy & Security → Location Services
3. 重置模拟器：Device → Erase All Content and Settings

### Q: 通知不工作
**A**: 
1. 在模拟器/设备的设置中允许通知
2. Settings → Notifications → Tocik → Allow Notifications

### Q: SwiftData错误
**A**: 
1. 确保最低部署目标为iOS 17.0+
2. 清理构建文件夹：⌘ + Shift + K
3. 重新构建项目

### Q: WebDAV连接失败
**A**: 
1. 检查服务器地址是否正确（必须以https://开头）
2. 确认用户名和密码正确
3. 某些WebDAV服务需要应用专用密码

## 测试数据

### 添加测试课程
1. 打开课程表
2. 点击右上角+号
3. 添加示例课程：
   - 课程名称：高等数学
   - 地点：教学楼A101
   - 星期：周一
   - 时间：09:00-10:40

### 添加测试待办
1. 打开待办事项
2. 点击右上角+号
3. 创建几个不同优先级的待办事项

### 测试番茄钟
1. 打开番茄时钟
2. 点击播放按钮开始
3. 可以使用跳过按钮快速测试完成通知

## 开发建议

### 调试技巧

1. **查看SwiftData数据**:
```swift
// 在任意View中添加
.onAppear {
    let descriptor = FetchDescriptor<YourModel>()
    let results = try? modelContext.fetch(descriptor)
    print("数据数量: \(results?.count ?? 0)")
}
```

2. **调试通知**:
```swift
// 查看所有待处理的通知
UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
    print("待处理通知: \(requests.count)")
    requests.forEach { print($0.identifier) }
}
```

3. **调试WeatherKit**:
```swift
// 在WeatherManager中添加更多日志
print("当前位置: \(location.coordinate)")
print("天气数据: \(currentWeather)")
```

### 性能优化

1. 使用 **Instruments** 分析性能
2. 注意SwiftData查询效率
3. 大量数据时考虑分页加载

## 下一步

项目已完全配置完成！您可以：

1. ✅ 运行应用测试所有功能
2. ✅ 根据需要自定义UI和颜色
3. ✅ 添加白噪音音频文件（专注模式）
4. ✅ 配置WebDAV服务器测试阅读器
5. ✅ 提交到TestFlight进行测试
6. ✅ 准备App Store提交材料

## 支持

如有问题，请查看：
- 项目README.md
- Apple官方文档
- SwiftUI/SwiftData文档

祝您开发愉快！🎉

