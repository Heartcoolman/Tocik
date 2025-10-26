# Xcode项目配置说明

## 重要：必须在Xcode中手动配置的项目

### 1. Info.plist权限配置

由于现代iOS项目使用Target的Info配置，需要在Xcode中手动添加权限描述：

#### 步骤：
1. 在Xcode中打开项目
2. 选择项目导航器中的 **Tocik** 项目
3. 选择 **TARGETS** → **Tocik**
4. 选择 **Info** 标签
5. 在 **Custom iOS Target Properties** 部分，点击 **+** 按钮添加以下键值对：

#### 需要添加的权限：

| Key | Type | Value |
|-----|------|-------|
| Privacy - Location When In Use Usage Description | String | 需要获取您的位置信息以提供天气预报服务 |
| Privacy - Location Always and When In Use Usage Description | String | 需要获取您的位置信息以提供天气预报服务 |

### 2. Capabilities配置

#### WeatherKit（必须）
1. 在 **Signing & Capabilities** 标签中
2. 点击 **+ Capability** 按钮
3. 搜索并添加 **WeatherKit**
4. ⚠️ 需要付费Apple Developer账号

#### Background Modes（可选，用于音频后台播放）
1. 点击 **+ Capability** 按钮
2. 搜索并添加 **Background Modes**
3. 勾选 **Audio, AirPlay, and Picture in Picture**

### 3. 签名配置

1. 在 **Signing & Capabilities** 标签中
2. **Team**: 选择您的开发团队
3. **Bundle Identifier**: 修改为唯一标识符（如：`com.yourname.Tocik`）
4. 确保 **Automatically manage signing** 已勾选

### 4. 最低部署目标

1. 在 **General** 标签下
2. **Minimum Deployments**: 设置为 **iOS 17.0**

### 5. Apple Developer网站配置

#### 启用WeatherKit:
1. 访问 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers**
4. 找到或创建您的App ID
5. 编辑App ID，勾选 **WeatherKit**
6. 保存更改

### 6. 构建并运行

完成以上配置后：
1. 清理构建文件夹：**⌘ + Shift + K**
2. 重新构建项目：**⌘ + B**
3. 运行应用：**⌘ + R**

## 快速检查清单

- [ ] 添加位置权限描述
- [ ] 添加WeatherKit Capability
- [ ] 配置Team和Bundle Identifier
- [ ] 设置最低部署目标为iOS 17.0
- [ ] 在开发者网站启用WeatherKit
- [ ] 清理并重新构建项目

## 常见问题

### Q: 编译错误 "Info.plist冲突"
**A**: 已删除自定义Info.plist，请按上述步骤在Xcode的Info标签中添加权限

### Q: WeatherKit相关错误
**A**: 确保：
- 使用付费开发者账号
- 在开发者网站启用WeatherKit
- Bundle Identifier与App ID匹配

---

配置完成后，项目即可正常运行！🎉

