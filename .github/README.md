# GitHub Actions 配置

本目录包含 Tocik 项目的 GitHub Actions 自动化配置。

## 📁 文件结构

```
.github/
├── workflows/
│   ├── build-ipa.yml          # 主要构建流程（自动触发）
│   └── build-archive.yml      # 备用构建流程（手动触发）
├── BUILD_GUIDE.md             # 详细构建指南
└── README.md                  # 本文件
```

## 🚀 快速开始

### 自动构建（推送触发）

推送代码到 `main` 分支会自动触发构建：

```bash
git push origin main
```

### 创建发布版本

创建 tag 会自动构建并创建 GitHub Release：

```bash
git tag -a v4.0.0 -m "Release v4.0.0"
git push origin v4.0.0
```

### 手动触发构建

1. 访问 [Actions](https://github.com/Heartcoolman/Tocik/actions)
2. 选择 workflow
3. 点击 "Run workflow"

## 📦 下载产物

构建完成后，可以在以下位置下载：

- **Artifacts**: Actions 页面 → 选择构建任务 → 下载 Artifacts（30天有效）
- **Releases**: [Releases 页面](https://github.com/Heartcoolman/Tocik/releases)（tag 触发的构建）

## 📖 详细文档

查看 [BUILD_GUIDE.md](BUILD_GUIDE.md) 获取：
- 完整的 workflow 说明
- 本地测试方法
- 安装 IPA 的方法
- 常见问题解答
- 高级配置选项

## ⚠️ 重要说明

- 生成的 IPA 文件是**未签名**的
- 无法直接安装到普通 iOS 设备
- 需要使用 AltStore、Sideloadly 等工具重新签名
- 或使用 Xcode 重新签名后安装

## 🔧 自定义

编辑 `workflows/*.yml` 文件来自定义构建流程。

常见修改：
- 修改触发条件
- 更改 Xcode 版本
- 添加测试步骤
- 配置通知

---

**详细说明请查看 [BUILD_GUIDE.md](BUILD_GUIDE.md)** 📚

