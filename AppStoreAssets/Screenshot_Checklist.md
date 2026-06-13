# FocusGuard App Store 截图清单

## ✅ 图标状态
- [x] 1024x1024 App Store 图标已生成
- [x] 图标已导入 Xcode 项目
- [x] 文件位置：`focus_mac/Assets.xcassets/AppIcon.iconset/icon_512x512@2x.png`

---

## 📸 截图准备清单

### 必需截图（至少 2 张）

#### 1. MacBook Pro 13" 主界面 - **必须**
- [ ] 截图已生成
- [ ] 尺寸：2880 x 1800 像素
- [ ] 内容：专注模式运行中
- [ ] 文件名：`Screenshot_01_MacBookPro_FocusMode.png`

#### 2. iPad Pro 12.9" 统计数据 - **必须**
- [ ] 截图已生成
- [ ] 尺寸：2048 x 2732 像素
- [ ] 内容：7 天历史数据图表
- [ ] 文件名：`Screenshot_02_iPadPro_Statistics.png`

---

### 推荐截图（最多 10 张）

#### 3. MacBook Pro 设置页面
- [ ] 截图已生成
- [ ] 尺寸：2880 x 1800 像素
- [ ] 内容：灵敏度调节、多语言切换
- [ ] 文件名：`Screenshot_03_MacBookPro_Settings.png`

#### 4. MacBook Pro 坐姿检测
- [ ] 截图已生成
- [ ] 尺寸：2880 x 1800 像素
- [ ] 内容：坐姿警告状态
- [ ] 文件名：`Screenshot_04_MacBookPro_PostureAlert.png`

#### 5. iPad Pro 抓拍相册
- [ ] 截图已生成
- [ ] 尺寸：2048 x 2732 像素
- [ ] 内容：抓拍照片展示
- [ ] 文件名：`Screenshot_05_iPadPro_Snapshots.png`

---

## 🎯 截图步骤

### 快速流程（5 分钟）

1. **准备应用**
   ```bash
   # 打开项目
   open focus_mac.xcodeproj
   
   # 运行应用
   # 在 Xcode 中点击 Run (⌘R)
   ```

2. **截取主界面**
   - 启动应用
   - 点击"开始检测"
   - 按 `⌘ + ⇧ + 4 + 空格`
   - 点击应用窗口
   - 截图保存到桌面

3. **截取统计页面**
   - 切换到"统计"标签
   - 按 `⌘ + ⇧ + 4 + 空格`
   - 点击应用窗口

4. **调整尺寸**（如需要）
   ```bash
   cd AppStoreAssets
   ./capture_screenshots.sh
   ```

5. **保存到指定目录**
   - 创建文件夹：`AppStoreAssets/Screenshots/`
   - 将所有截图移动到此文件夹

---

## 📐 尺寸要求

### macOS 截图
- **MacBook Pro 13"**: 2880 x 1800 像素
- **MacBook Pro 15"**: 2880 x 1800 像素
- **iMac 21.5"**: 1920 x 1080 像素
- **iMac 27"**: 2560 x 1440 像素

### iPad 截图
- **iPad Pro 12.9" (第 6 代)**: 2048 x 2732 像素 ⭐ **必须**

---

## 🛠️ 工具使用

### 方法 1: Xcode 模拟器（最标准）

```
1. Xcode → File → New Simulator Window
2. 选择 Mac 设备
3. 运行应用
4. 模拟器菜单 → File → Capture Screen (⌘S)
5. 截图自动保存到桌面
```

### 方法 2: macOS 原生截图（最快速）

```
截取窗口：
⌘ + ⇧ + 4 + 空格 → 点击窗口

截取区域：
⌘ + ⇧ + 4 → 选择区域

截取全屏：
⌘ + ⇧ + 3
```

### 方法 3: 使用辅助脚本

```bash
cd AppStoreAssets
./capture_screenshots.sh
```

---

## 🎨 添加设备边框（推荐）

### 在线工具

1. **appletoscreenshot.com**
   - 免费
   - 快速
   - 支持多种设备

2. **previewed.app**
   - 专业模板
   - 批量处理

3. **shots.pro**
   - 简单易用
   - 免费

---

## ✅ 质量检查

提交前确认：

- [ ] 尺寸符合要求
- [ ] 截图清晰无模糊
- [ ] 无菜单栏干扰
- [ ] 展示核心功能
- [ ] 无拼写错误
- [ ] 无敏感信息
- [ ] 已添加设备边框（可选）
- [ ] 格式为 PNG
- [ ] 文件大小 < 10MB

---

## 📤 上传到 App Store Connect

### 步骤

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择你的应用
3. 点击"App Store"标签
4. 滚动到"版本信息"部分
5. 点击"添加"上传截图
6. 选择设备类型
7. 拖放截图或点击上传
8. 调整顺序（重要的放前面）
9. 点击"存储"

### 截图顺序建议

1. 主界面 - 专注模式（最重要）
2. 统计数据页面
3. 设置页面
4. 特色功能展示
5. 其他功能

---

## 💡 最佳实践

### 应该做的
✅ 展示核心功能
✅ 使用真实数据
✅ 保持截图清晰
✅ 添加设备边框
✅ 遵循 Apple 设计规范

### 不应该做的
❌ 使用模糊截图
❌ 包含敏感信息
❌ 添加水印或文字
❌ 使用过时的 UI
❌ 截图尺寸不标准

---

## 📞 常见问题

### Q: 截图尺寸不对怎么办？
A: 使用 Preview 应用或运行 `capture_screenshots.sh` 脚本调整

### Q: 截图有菜单栏怎么办？
A: 使用 `⌘ + ⇧ + 4 + 空格` 截取窗口，或使用 Xcode 模拟器

### Q: 应用数据是空的怎么办？
A: 先使用应用几天，生成真实数据后再截图

### Q: 需要多少张截图？
A: 最少 2 张，最多 10 张。建议准备 5 张展示不同功能

---

**最后更新**: 2026-06-09  
**文档版本**: 1.0
