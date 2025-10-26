# GitHub Actions 自动构建指南

本项目配置了 GitHub Actions 自动构建系统，可以自动生成未签名的 IPA 文件。

## 📋 目录

- [Workflow 说明](#workflow-说明)
- [触发方式](#触发方式)
- [下载构建产物](#下载构建产物)
- [本地测试](#本地测试)
- [常见问题](#常见问题)

---

## Workflow 说明

### 1. `build-ipa.yml` - 主要构建流程

**功能**：
- ✅ 自动构建未签名的 IPA
- ✅ 提取版本号并重命名文件
- ✅ 上传为 GitHub Artifacts
- ✅ 在创建 tag 时自动发布 Release

**触发条件**：
- 推送到 `main` 分支
- 创建 `v*` 标签（如 `v4.0.0`）
- Pull Request 到 `main`
- 手动触发

### 2. `build-archive.yml` - 备用构建流程

**功能**：
- ✅ 构建 Xcode Archive
- ✅ 同时生成 `.xcarchive.zip` 和 `.ipa`
- ✅ 仅手动触发，更可控

---

## 触发方式

### 方式一：推送代码触发

```bash
git add .
git commit -m "Update app"
git push origin main
```

推送后，GitHub Actions 会自动开始构建。

### 方式二：创建 Tag 发布

```bash
# 创建版本标签
git tag -a v4.0.0 -m "Release version 4.0.0"

# 推送标签
git push origin v4.0.0
```

这会触发构建，并自动创建 GitHub Release。

### 方式三：手动触发

1. 访问 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **Build IPA** 或 **Build Archive (Alternative)**
4. 点击 **Run workflow**
5. 选择分支，点击绿色的 **Run workflow** 按钮

---

## 下载构建产物

### 从 Actions 下载

1. 访问：https://github.com/Heartcoolman/Tocik/actions
2. 点击最新的构建任务
3. 滚动到页面底部的 **Artifacts** 部分
4. 下载 `Tocik-IPA` 文件（自动过期时间：30天）

### 从 Releases 下载（Tag 触发的构建）

1. 访问：https://github.com/Heartcoolman/Tocik/releases
2. 找到对应的版本
3. 在 **Assets** 部分下载 IPA 文件

---

## 文件说明

构建完成后会生成以下文件：

| 文件名 | 说明 | 大小 |
|--------|------|------|
| `Tocik-v4.0.0-build1-unsigned.ipa` | 未签名的 IPA 文件 | ~50-100MB |
| `Tocik.xcarchive.zip` | Xcode Archive 压缩包 | ~100-200MB |
| `build-logs` | 构建日志（失败时） | 小 |

---

## 安装未签名的 IPA

### ⚠️ 重要提示

未签名的 IPA 文件**无法直接安装**到普通 iOS 设备上。需要以下任一条件：

### 方法一：使用 AltStore / Sideloadly

**步骤**：

1. **安装 AltStore**（推荐）
   - macOS: 下载 [AltServer](https://altstore.io/)
   - Windows: 下载 [AltStore](https://altstore.io/)

2. **通过 AltStore 安装**
   ```
   1. 在设备上打开 AltStore
   2. 点击 "+" 号
   3. 选择下载的 IPA 文件
   4. 输入 Apple ID 和密码
   5. 等待签名和安装完成
   ```

**限制**：
- ⏰ 每 7 天需要重新签名一次
- 📱 最多 3 个应用（免费 Apple ID）
- 💰 或使用付费开发者账号（99$/年）无限制

### 方法二：使用 Xcode 重新签名

如果你有 Mac 和 Xcode：

```bash
# 1. 解压 IPA
unzip Tocik-unsigned.ipa

# 2. 在 Xcode 中打开项目并签名
# 打开 Tocik.xcodeproj
# 设置你的开发团队
# 重新构建

# 3. 通过 Xcode 安装到设备
# 连接设备
# Product -> Run
```

### 方法三：越狱设备

越狱设备可以直接安装未签名的 IPA：

```bash
# 使用 Filza 或其他工具安装
```

---

## 本地测试

在推送前，可以在本地测试构建：

```bash
cd Tocik/Tocik

# 清理旧构建
rm -rf build

# 构建 Archive
xcodebuild archive \
  -project Tocik.xcodeproj \
  -scheme Tocik \
  -configuration Release \
  -archivePath build/Tocik.xcarchive \
  -sdk iphoneos \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# 创建 IPA
mkdir -p build/Payload
cp -r build/Tocik.xcarchive/Products/Applications/Tocik.app build/Payload/
cd build
zip -r Tocik-unsigned.ipa Payload

echo "✅ IPA created at: build/Tocik-unsigned.ipa"
```

---

## 创建正式发布

### 创建 Release 的完整流程

```bash
# 1. 确保代码已提交
git add .
git commit -m "Release v4.0.0"
git push

# 2. 创建并推送标签
git tag -a v4.0.0 -m "Release version 4.0.0

## What's New
- 新功能 1
- 新功能 2
- Bug 修复

详见 CHANGELOG.md"

git push origin v4.0.0

# 3. GitHub Actions 会自动：
#    - 构建 IPA
#    - 创建 Release
#    - 上传 IPA 到 Release
```

### Release 页面

访问：https://github.com/Heartcoolman/Tocik/releases

你会看到：
- 📦 自动生成的 Release
- 📝 Release Notes
- 📎 附带的 IPA 文件
- 🏷️ 版本标签

---

## 自定义 Workflow

### 修改触发条件

编辑 `.github/workflows/build-ipa.yml`：

```yaml
on:
  push:
    branches:
      - main
      - develop  # 添加其他分支
    tags:
      - 'v*'
  schedule:
    - cron: '0 0 * * 0'  # 每周日自动构建
```

### 修改 Xcode 版本

```yaml
- name: Set up Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.2'  # 修改这里
```

### 添加构建通知

可以添加 Slack、Discord、邮件等通知：

```yaml
- name: Send notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build completed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 常见问题

### ❓ 构建失败怎么办？

1. **检查构建日志**：
   - Actions 页面 → 点击失败的任务 → 查看详细日志
   - 下载 `build-logs` artifact

2. **常见错误**：

   **错误**: `xcodebuild: error: Unable to find a destination`
   ```
   解决：检查 scheme 名称是否正确
   ```

   **错误**: `Code signing is required`
   ```
   解决：已在 workflow 中禁用，检查配置
   ```

   **错误**: `No such file or directory`
   ```
   解决：检查路径配置，working-directory 是否正确
   ```

### ❓ IPA 文件太大？

可以在 workflow 中添加压缩：

```yaml
- name: Compress IPA
  run: |
    zip -9 Tocik-compressed.zip Tocik-unsigned.ipa
```

### ❓ 如何添加 TestFlight？

需要添加代码签名和证书配置：

1. 添加 GitHub Secrets：
   - `APPLE_CERTIFICATE`
   - `APPLE_CERT_PASSWORD`
   - `PROVISIONING_PROFILE`

2. 修改 workflow 添加签名步骤

3. 使用 `fastlane` 上传到 TestFlight

（详细步骤需要付费开发者账号）

### ❓ 如何清理旧的 Artifacts？

GitHub 会自动删除 30 天前的 artifacts。

手动删除：
1. Settings → Actions → Artifacts
2. 选择要删除的 artifacts

---

## 高级用法

### 使用 Fastlane

创建 `Fastfile`：

```ruby
default_platform(:ios)

platform :ios do
  desc "Build unsigned IPA"
  lane :build_unsigned do
    build_app(
      workspace: "Tocik.xcworkspace",
      scheme: "Tocik",
      export_method: "development",
      skip_codesigning: true
    )
  end
end
```

在 workflow 中使用：

```yaml
- name: Build with Fastlane
  run: |
    bundle install
    bundle exec fastlane build_unsigned
```

### 矩阵构建（多配置）

```yaml
strategy:
  matrix:
    configuration: [Debug, Release]
    platform: [iOS, iPadOS]
    
steps:
  - name: Build ${{ matrix.configuration }}
    run: |
      xcodebuild archive \
        -configuration ${{ matrix.configuration }} \
        ...
```

---

## 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcodebuild 参考](https://developer.apple.com/documentation/xcode/running-xcodebuild)
- [AltStore](https://altstore.io/)
- [Fastlane](https://fastlane.tools/)

---

## 总结

✅ **已配置的功能**：
- 自动构建未签名 IPA
- Tag 触发自动发布
- Artifacts 自动上传
- 构建日志记录

❌ **未包含的功能**（需要额外配置）：
- 代码签名
- TestFlight 上传
- App Store 发布
- 自动化测试

---

**如有问题，请在 GitHub Issues 中反馈！** 🚀

