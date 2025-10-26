# Tocik - 智能学习助手

<div align="center">

**一款功能强大的 iOS/iPadOS 学习助手应用**

集成学习管理、AI 智能分析、多功能工具于一体

[![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B%20%7C%20iPadOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-4.0.0-brightgreen.svg)](CHANGELOG.md)

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [技术架构](#-技术架构) • [更新日志](CHANGELOG.md) • [贡献指南](#-贡献指南)

</div>

---

## 📖 项目简介

Tocik 是一款专为学生和学习者设计的全方位智能学习助手应用。通过整合强大的学习管理工具、AI 驱动的智能分析系统和丰富的实用功能，帮助用户提升学习效率、养成良好习惯，实现个人成长目标。

### ✨ 核心亮点

- 🎯 **全面的学习管理** - 番茄时钟、待办事项、课程表、习惯追踪一站式解决方案
- 🤖 **AI 智能助手** - 集成 DeepSeek AI，提供智能学习分析和个性化推荐
- 📊 **数据可视化** - 直观展示学习数据、趋势分析和个人成长轨迹
- 🎨 **现代化设计** - 玻璃态卡片、流畅动画、多主题支持
- 📱 **iPad 优化** - 针对大屏幕优化的界面布局和交互体验
- 🔄 **云端同步** - 支持 WebDAV 云同步，多设备无缝协作

---

## 🎯 功能特性

### 📚 学习管理

#### 核心工具
- **🍅 番茄时钟** - 25分钟专注工作法，支持多种学习模式
  - 标准番茄、短休息、长休息模式切换
  - 番茄钟统计和数据分析
  - 与待办事项和科目关联
  - 学习时长趋势图

- **✅ 待办事项** - 强大的任务管理系统
  - 优先级设置（高/中/低）
  - 截止日期提醒
  - 子任务支持
  - 重复任务规则
  - 任务评论和附件
  - 依赖关系管理
  - 批量操作

- **📅 课程表** - 可视化周课程安排
  - 支持自定义课程时间
  - 课程笔记和资料管理
  - 课程详情和教师信息
  - 考试提醒

- **📆 日历** - 月视图日历与事件管理
  - 事件快速创建
  - 重复事件支持
  - 日程提醒

- **🎯 习惯追踪** - 养成良好习惯
  - 每日打卡统计
  - 连续打卡记录
  - 习惯完成度热力图
  - 习惯养成分析

- **🎓 目标管理** - 设定和追踪学习目标
  - 长期/短期目标设置
  - 进度可视化
  - 里程碑记录

#### 学习辅助

- **❌ 错题本** - 智能错题整理与复习
  - 拍照识别错题
  - 错题分类和标签
  - 定期复习提醒
  - 错题分析报告

- **🎴 闪卡学习** - 间隔重复记忆系统
  - SM-2 算法优化复习时间
  - 多种卡片类型（文本/图片/多选）
  - 学习曲线可视化
  - 卡组管理

- **📝 笔记系统** - Markdown 编辑器
  - 实时预览
  - 标签分类
  - 全文搜索
  - 笔记历史版本
  - 笔记模板库

- **💡 灵感收集** - 快速记录想法
  - 一键快速记录
  - 语音备忘录
  - 图片附件

- **📖 知识图谱** - 可视化知识结构
  - 知识节点关联
  - 思维导图展示

- **🎓 学习日志** - 记录学习历程
  - 情绪追踪
  - 每日总结

### 🤖 AI 智能功能

- **AI 学习分析** - 智能数据洞察
  - 学习习惯分析
  - 时间分配优化建议
  - 薄弱环节识别
  - 学习效率评估

- **智能推荐系统** - 个性化建议
  - 学习计划推荐
  - 复习时间优化
  - 任务优先级建议
  - 异常行为检测

- **DeepSeek AI 对话** - 智能学习助手
  - 学习问题解答
  - 知识点讲解
  - 学习方法指导
  - 个性化对话历史

- **根因分析** - 深度问题诊断
  - 学习障碍分析
  - 改进建议生成

### 📊 数据统计与分析

- **📈 数据可视化**
  - 学习时长统计
  - 任务完成率
  - 习惯打卡热力图
  - 科目时间分配
  - 趋势图表

- **🏆 成就系统**
  - 学习里程碑
  - 徽章收集
  - 个人记录
  - 排行榜（可选）

- **📋 个人报告**
  - 周报/月报自动生成
  - 学习轨迹回顾
  - 个人成长分析

### 🛠️ 实用工具

- **📚 TXT 阅读器** - 支持 WebDAV 云同步
  - 书签管理
  - 阅读进度保存
  - 字体和主题自定义
  - 云端书籍浏览

- **🔢 计算器** - 标准计算器
  - 历史记录
  - 科学计算模式

- **🔄 单位换算** - 多种单位转换
  - 长度、重量、温度
  - 货币、面积、体积
  - 时间、速度

- **🎵 专注模式** - 白噪音播放器
  - 多种环境音效
  - 定时关闭
  - 自定义播放列表

- **🎙️ 语音备忘** - 录音功能
  - 高质量录音
  - 标签分类
  - 快速回放

- **📱 QR 扫描** - 二维码扫描
  - 快速识别
  - 历史记录

- **⏱️ 倒数日** - 重要日期倒计时
  - 考试倒计时
  - 节日提醒
  - 自定义事件

### 🎨 个性化定制

- **主题系统** - 多种主题切换
  - 亮色/暗色模式
  - 自定义配色方案
  - 玻璃态效果

- **辅助功能** - 无障碍支持
  - 大字体模式
  - 语音朗读
  - 高对比度

- **快捷键支持** - 提升效率
  - iPad 键盘快捷键
  - 自定义操作

---

## 🚀 快速开始

### 系统要求

- **iOS** 17.0 或更高版本
- **iPadOS** 17.0 或更高版本
- **Xcode** 15.0+ （开发需要）
- **Swift** 5.9+

### 安装步骤

#### 1. 克隆项目

```bash
git clone https://github.com/Heartcoolman/Tocik.git
cd Tocik
```

#### 2. 打开项目

```bash
cd Tocik/Tocik
open Tocik.xcodeproj
```

#### 3. 配置 Xcode

**Signing & Capabilities:**

1. 选择你的开发团队（Development Team）
2. 修改 Bundle Identifier（如果需要）
3. 添加必要的 Capabilities：
   - ✅ WeatherKit（需要付费开发者账号）
   - ✅ Background Modes（可选，用于音频播放）
   - ✅ Push Notifications（可选）

**权限配置:**

在 `Info.plist` 中添加以下权限描述（Xcode会自动提示）：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要您的位置信息以提供准确的天气预报</string>

<key>NSMicrophoneUsageDescription</key>
<string>需要访问麦克风以录制语音备忘录</string>

<key>NSCameraUsageDescription</key>
<string>需要访问相机以扫描二维码和拍摄错题</string>
```

> 详细配置说明请参考 [Tocik/XCODE_CONFIGURATION.md](Tocik/XCODE_CONFIGURATION.md)

#### 4. WeatherKit 配置（可选）

如果需要使用天气功能：

1. 访问 [Apple Developer](https://developer.apple.com)
2. 在 Identifiers 中为你的 App ID 启用 WeatherKit
3. 在 Xcode 的 Signing & Capabilities 中添加 WeatherKit capability

> ⚠️ **注意**: WeatherKit 需要付费开发者账号

#### 5. 构建并运行

选择目标设备（模拟器或真机），然后点击运行（⌘R）

---

## 🏗️ 技术架构

### 核心技术栈

- **SwiftUI** - 声明式 UI 框架，构建现代化界面
- **SwiftData** - iOS 17+ 原生数据持久化框架
- **Combine** - 响应式编程框架
- **Swift Concurrency** - async/await 异步编程

### 系统框架

- **WeatherKit** - 系统级天气数据服务
- **UserNotifications** - 本地通知管理
- **CoreLocation** - 位置服务
- **AVFoundation** - 音频录制与播放
- **Vision** - OCR 文字识别（错题本功能）
- **Charts** - 数据可视化图表

### 项目架构

```
Tocik/
├── Tocik/                          # 主项目目录
│   ├── TocikApp.swift              # 应用入口
│   ├── Configuration/              # 配置文件
│   │   ├── AppCoordinator.swift    # 应用协调器
│   │   ├── DatabaseConfigurator.swift  # 数据库配置
│   │   └── SystemInitializer.swift # 系统初始化
│   │
│   ├── Models/                     # 数据模型层
│   │   ├── Achievement.swift       # 成就模型
│   │   ├── CalendarEvent.swift     # 日历事件
│   │   ├── CourseItem.swift        # 课程项目
│   │   ├── FlashCard.swift         # 闪卡
│   │   ├── Goal.swift              # 目标
│   │   ├── Habit.swift             # 习惯
│   │   ├── Note.swift              # 笔记
│   │   ├── PomodoroSession.swift   # 番茄钟会话
│   │   ├── TodoItem.swift          # 待办事项
│   │   ├── WrongQuestion.swift     # 错题
│   │   └── ...                     # 其他模型
│   │
│   ├── Views/                      # 视图层
│   │   ├── AI/                     # AI 助手界面
│   │   ├── Pomodoro/               # 番茄时钟
│   │   ├── Todo/                   # 待办事项
│   │   ├── Timetable/              # 课程表
│   │   ├── Calendar/               # 日历
│   │   ├── Habit/                  # 习惯追踪
│   │   ├── FlashCard/              # 闪卡学习
│   │   ├── Note/                   # 笔记
│   │   ├── Stats/                  # 统计分析
│   │   ├── Components/             # 可复用组件
│   │   └── ...                     # 其他视图
│   │
│   ├── ViewModels/                 # 视图模型层
│   │   └── StudyDataViewModel.swift
│   │
│   ├── Utilities/                  # 工具类
│   │   ├── AI/                     # AI 相关
│   │   │   ├── DeepSeekManager.swift       # DeepSeek API
│   │   │   ├── SmartAnalyzer.swift         # 智能分析
│   │   │   ├── HybridAnalysisEngine.swift  # 混合分析引擎
│   │   │   └── SuggestionEngine.swift      # 推荐引擎
│   │   ├── Managers/               # 管理器
│   │   │   ├── NotificationManager.swift   # 通知管理
│   │   │   ├── WebDAVManager.swift         # WebDAV 管理
│   │   │   └── AchievementManager.swift    # 成就管理
│   │   ├── Extensions.swift        # Swift 扩展
│   │   ├── Theme.swift             # 主题系统
│   │   ├── SM2Algorithm.swift      # 间隔重复算法
│   │   └── ...                     # 其他工具
│   │
│   └── Assets.xcassets/            # 资源文件
│
├── CHANGELOG.md                    # 更新日志
├── README.md                       # 本文件
└── Tocik/                          # 文档目录
    ├── SETUP_GUIDE.md              # 设置指南
    ├── XCODE_CONFIGURATION.md      # Xcode 配置
    └── ...                         # 其他文档
```

### 设计模式

- **MVVM** - Model-View-ViewModel 架构
- **Repository Pattern** - 数据访问层抽象
- **Coordinator Pattern** - 导航协调
- **Singleton** - 单例管理器（NotificationManager, ThemeStore 等）
- **Observer Pattern** - 通过 Combine 实现响应式更新

### 数据流

```
View ←→ ViewModel ←→ Repository ←→ SwiftData
                ↓
           Utilities (Managers, Services)
```

---

## 📱 使用说明

### WebDAV 云同步配置

**阅读器支持通过 WebDAV 同步书籍：**

1. 打开阅读器页面
2. 点击左上角的云图标 ☁️
3. 点击设置图标 ⚙️
4. 输入以下信息：
   - **服务器地址**（如：`https://dav.jianguoyun.com/dav/`）
   - **用户名**
   - **密码**
5. 点击保存并连接

**支持的 WebDAV 服务：**
- [坚果云](https://www.jianguoyun.com/) - `https://dav.jianguoyun.com/dav/`
- Nextcloud
- ownCloud
- 其他符合标准的 WebDAV 服务

### AI 功能使用

**配置 DeepSeek API（可选）：**

> ⚠️ 需要自行申请 DeepSeek API Key

1. 访问 [DeepSeek](https://www.deepseek.com/) 注册账号
2. 获取 API Key
3. 在应用设置中配置 API Key
4. 开始使用 AI 助手功能

---

## 🛠️ 开发指南

### 环境准备

```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 克隆项目
git clone https://github.com/Heartcoolman/Tocik.git
cd Tocik
```

### 代码规范

项目遵循以下代码规范：
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- SwiftLint 配置（见 `.swiftlint.yml`）

### 测试

```bash
# 运行单元测试
⌘ + U 在 Xcode 中

# 或使用命令行
xcodebuild test -scheme Tocik -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. **Fork** 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 **Pull Request**

### 贡献类型

- 🐛 报告 Bug
- ✨ 提出新功能建议
- 📝 改进文档
- 💻 提交代码
- 🎨 UI/UX 改进
- 🌍 翻译和本地化

### 开发建议

- 遵循现有的代码风格
- 编写清晰的提交信息
- 添加必要的注释和文档
- 确保代码通过测试
- 一个 PR 只做一件事

---

## 📋 路线图

### v4.1.0（计划中）

- [ ] iCloud 同步支持
- [ ] 主屏幕小组件（Widget）
- [ ] Apple Watch 配套应用
- [ ] Siri 快捷指令集成
- [ ] 数据导出（PDF/Excel）

### v4.2.0（计划中）

- [ ] 多语言支持（英语、日语）
- [ ] 深色模式优化
- [ ] iPad 分屏多任务
- [ ] 更多主题和配色方案
- [ ] 学习小组协作功能

### 长期规划

- [ ] macOS 版本
- [ ] Apple Vision Pro 适配
- [ ] 家长监控模式
- [ ] 学校版团队功能

> 详细更新日志请查看 [CHANGELOG.md](CHANGELOG.md)

---

## ⚠️ 注意事项

### WeatherKit 限制

- ✅ 需要付费 Apple Developer 账号（$99/年）
- ⚠️ 每月有 API 调用次数限制
- 如无 WeatherKit 权限，天气功能将无法使用

### 专注模式音频

- 当前版本未包含音频文件
- 需要自行添加白噪音文件到项目
- 支持格式：MP3、M4A

### 性能建议

- 定期清理已完成的待办事项
- 删除不需要的旧笔记和阅读记录
- SwiftData 会自动优化数据库性能

---

## 📄 许可证

本项目采用 **MIT 许可证** - 详见 [LICENSE](LICENSE) 文件

```
MIT License

Copyright (c) 2025 Tocik Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👥 团队

**Tocik Team** © 2025

---

## 🙏 致谢

感谢以下开源项目和资源：

- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Apple
- [SwiftData](https://developer.apple.com/xcode/swiftdata/) - Apple
- [DeepSeek](https://www.deepseek.com/) - AI 对话能力
- 所有贡献者和测试用户

---

## 📞 联系我们

- **GitHub Issues**: [提交问题](https://github.com/Heartcoolman/Tocik/issues)
- **Pull Requests**: [贡献代码](https://github.com/Heartcoolman/Tocik/pulls)
- **Discussions**: [参与讨论](https://github.com/Heartcoolman/Tocik/discussions)

---

## 📸 预览

> 截图和演示视频即将添加...

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个 Star！⭐**

**享受使用 Tocik 提升你的学习效率！** 🚀

Made with ❤️ by Tocik Team

</div>

