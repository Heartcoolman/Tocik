# Tocik - iOS/iPadOS 多功能工具集合

一个功能丰富的iOS/iPadOS应用，集成了13个实用工具模块，帮助您提高生产力和生活质量。

## 功能模块

### 核心工具
1. **番茄时钟** - 25分钟工作法，提高专注力
2. **待办事项** - 任务管理，支持优先级和提醒
3. **课程表** - 可视化周课程安排
4. **日历** - 月视图日历与事件管理
5. **习惯追踪** - 养成良好习惯，连续打卡统计

### 信息工具
6. **天气** - 基于WeatherKit的实时天气和7天预报
7. **倒数日** - 重要日期倒计时
8. **数据统计** - 可视化展示各项数据

### 内容工具
9. **TXT阅读器** - 支持WebDAV云同步的文本阅读器
10. **笔记** - Markdown编辑器，支持标签分类

### 实用工具
11. **计算器** - 标准计算器，带历史记录
12. **单位换算** - 支持长度、重量、温度等多种单位转换
13. **专注模式** - 白噪音播放器，提升专注力

## 技术栈

- **SwiftUI** - 现代化UI框架
- **SwiftData** - iOS 17+数据持久化
- **WeatherKit** - 系统级天气数据
- **UserNotifications** - 本地通知
- **CoreLocation** - 位置服务
- **AVFoundation** - 音频播放

## 项目配置

### 必需配置

#### 1. Xcode配置
打开项目后，需要在Xcode中进行以下配置：

**Signing & Capabilities:**
- 添加您的开发团队
- 配置Bundle Identifier
- 添加以下Capabilities:
  - WeatherKit (需要付费开发者账号)
  - Background Modes (可选，用于音频播放)

#### 2. WeatherKit设置
1. 登录 [Apple Developer](https://developer.apple.com)
2. 在Identifiers中为您的App ID启用WeatherKit
3. 在Xcode的Signing & Capabilities中添加WeatherKit

#### 3. 权限配置
需要在Xcode的Info标签中手动添加权限描述：
- `Privacy - Location When In Use Usage Description` - 天气功能需要位置权限
- 通知权限会在应用启动时自动请求
- 详见 `XCODE_CONFIGURATION.md` 文件获取详细配置步骤

### 系统要求

- iOS 17.0+
- iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 项目结构

```
Tocik/
├── TocikApp.swift              # 应用入口
├── ContentView.swift           # 主TabView
├── Info.plist                  # 权限配置
├── Models/                     # 数据模型
│   ├── PomodoroSession.swift
│   ├── CourseItem.swift
│   ├── CalendarEvent.swift
│   ├── ReadingBook.swift
│   ├── TodoItem.swift
│   ├── Habit.swift
│   ├── Countdown.swift
│   └── Note.swift
├── Views/                      # 视图组件
│   ├── Pomodoro/              # 番茄时钟
│   ├── Todo/                  # 待办事项
│   ├── Timetable/             # 课程表
│   ├── Calendar/              # 日历
│   ├── Habit/                 # 习惯追踪
│   ├── Weather/               # 天气
│   ├── Countdown/             # 倒数日
│   ├── Stats/                 # 统计
│   ├── Reader/                # 阅读器
│   ├── Note/                  # 笔记
│   ├── Calculator/            # 计算器
│   ├── Converter/             # 单位换算
│   └── Focus/                 # 专注模式
└── Utilities/                  # 工具类
    ├── Theme.swift            # 主题配置
    ├── Extensions.swift       # 扩展方法
    ├── NotificationManager.swift  # 通知管理
    ├── WeatherManager.swift   # 天气管理
    └── WebDAVManager.swift    # WebDAV管理
```

## 使用说明

### WebDAV配置（阅读器功能）

1. 打开阅读器页面
2. 点击左上角的云图标
3. 点击设置图标配置WebDAV服务器
4. 输入服务器地址、用户名和密码

**支持的WebDAV服务：**
- 坚果云：`https://dav.jianguoyun.com/dav/`
- Nextcloud
- ownCloud
- 其他标准WebDAV服务

### 数据同步

所有数据使用SwiftData本地存储，自动保存。如需跨设备同步，可以考虑：
- 使用WebDAV同步阅读器内容
- 未来版本可能添加iCloud同步支持

## 注意事项

### WeatherKit限制
- 需要付费Apple Developer账号
- 每月有API调用限额
- 如无WeatherKit权限，天气功能将无法使用

### 专注模式音频
- 当前版本未包含实际音频文件
- 需要自行添加白噪音音频文件到项目
- 音频文件格式建议：MP3或M4A，循环播放

### 性能优化建议
- 定期清理已完成的待办事项
- 删除不需要的旧笔记和阅读记录
- SwiftData会自动管理数据库性能

## 开发计划

### 未来功能
- [ ] iCloud同步支持
- [ ] 主屏幕小组件
- [ ] iPad分屏优化
- [ ] 深色模式优化
- [ ] 更多白噪音选项
- [ ] 数据导出功能
- [ ] 更多图表类型

### 已知问题
- 专注模式暂无实际音频文件
- 阅读器书签功能待完善
- 部分iPad适配需优化

## 贡献

欢迎提交Issue和Pull Request！

## 许可证

MIT License

## 作者

Tocik Team - 2025

---

**享受使用Tocik提升您的生产力！** 🚀

