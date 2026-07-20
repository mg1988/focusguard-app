# FocusGuard 快速上架指南 🚀

> **当前状态**: 图标已准备完成，开始截图流程
> **更新日期**: 2026-06-09

---

## ✅ 已完成的任务

### 1. App Store 图标 (1024x1024)
- ✅ 使用 AI 生成专业图标
- ✅ 导入到 Xcode 项目
- ✅ 文件位置：
  - 原始文件：`doc/logo-1024.png`
  - App Store 版：`AppStoreAssets/AppStoreIcon_1024x1024.png`
  - Xcode 已导入：`focus_mac/Assets.xcassets/AppIcon.iconset/icon_512x512@2x.png`

### 2. 截图辅助工具
- ✅ 截图指南文档：`GenerateScreenshots.md`
- ✅ 自动化脚本：`capture_screenshots.sh`
- ✅ 检查清单：`Screenshot_Checklist.md`

---

## 📋 剩余任务清单

### 🔴 第一优先级（必须完成）

#### 1. 准备 App Store 截图 ⏳ **进行中**
- [ ] 截取主界面（专注模式运行中）
- [ ] 截取统计数据页面
- [ ] 截取设置页面
- [ ] 调整尺寸为 2880x1800 (桌面) 和 2048x2732 (iPad)
- [ ] 保存到 `AppStoreAssets/Screenshots/` 目录

**快速操作**:
```bash
cd AppStoreAssets
./capture_screenshots.sh
```

#### 2. 部署法律文档网页 ⏳
- [ ] 部署隐私政策到 https://www.focusguard.app/privacy
- [ ] 部署使用条款到 https://www.focusguard.app/terms
- [ ] 部署技术支持到 https://www.focusguard.app/support

**替代方案**（如无服务器）:
- 使用 GitHub Pages（免费）
- 使用 Notion 页面
- 使用飞书文档公开链接

#### 3. Apple Developer 配置 ⏳
- [ ] 确认 Apple Developer 账号有效（$99/年）
- [ ] 创建 Distribution Certificate
- [ ] 创建 App Store Provisioning Profile
- [ ] 在 Xcode 中配置签名

**操作步骤**:
```
1. 打开 Xcode → Preferences → Accounts
2. 选择你的 Apple ID
3. 点击 Manage Certificates
4. 点击 + 号 → Apple Distribution
5. 等待证书生成
```

#### 4. App Store Connect 创建应用 ⏳
- [ ] 登录 https://appstoreconnect.apple.com
- [ ] 创建新应用
- [ ] 填写应用名称：FocusGuard - 智能专注助手
- [ ] Bundle ID: com.mg.focus-mac
- [ ] 填写基本信息

---

### 🟡 第二优先级（强烈推荐）

#### 5. TestFlight 测试 ⏳
- [ ] 在 Xcode 中 Archive 并上传
- [ ] 在 App Store Connect 添加内部测试员
- [ ] 发送测试邀请
- [ ] 收集反馈并修复问题

#### 6. 完善应用信息 ⏳
- [ ] 副标题（30 字符）：AI 驱动的效率提升工具
- [ ] 关键词（100 字符）：专注，效率，番茄钟，坐姿，提醒，AI，面部识别，工作，学习，时间管理
- [ ] 应用描述（中英文已准备）
- [ ] 更新说明（首发版本）

---

### 🟢 第三优先级（优化项）

#### 7. 预览视频（可选）
- [ ] 录制 15-30 秒功能演示
- [ ] 分辨率 1920x1080 或更高
- [ ] 上传到 App Store Connect

#### 8. 内购功能（如计划变现）
- [ ] 在 App Store Connect 创建内购项目
- [ ] 集成 StoreKit
- [ ] 测试购买流程

---

## 🎯 最快上架流程（3 天）

### Day 1: 截图与配置
```
上午:
  9:00 - 10:00  截取所有必需截图
  10:00 - 11:00  调整截图尺寸并添加边框
  11:00 - 12:00  配置 Apple Developer 证书

下午:
  14:00 - 15:00  部署隐私政策网页
  15:00 - 16:00  在 App Store Connect 创建应用
  16:00 - 17:00  填写所有应用信息
```

### Day 2: 构建与提交
```
上午:
  9:00 - 10:00   Xcode Archive 并上传
  10:00 - 11:00  上传截图到 App Store Connect
  11:00 - 12:00  最终检查所有信息

下午:
  14:00 - 15:00  提交审核
  15:00 - 17:00  等待审核状态更新
```

### Day 3: 审核与发布
```
全天:
  - 监控审核状态
  - 如有问题及时回复
  - 审核通过后设置发布日期
```

---

## 📞 关键信息汇总

### 应用信息
- **名称**: FocusGuard - 智能专注助手
- **Bundle ID**: com.mg.focus-mac
- **版本**: 1.0
- **构建**: 1
- **分类**: 生产力（主）+ 健康健美（次）
- **年龄分级**: 4+

### 技术支持
- **隐私政策**: https://www.focusguard.app/privacy
- **使用条款**: https://www.focusguard.app/terms
- **技术支持**: https://www.focusguard.app/support
- **联系邮箱**: support@focusguard.app

### 开发团队
- **Team ID**: U4AF57UZM2
- **Development Team**: 已配置

---

## 🔗 快速链接

### Apple 官方
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer](https://developer.apple.com)
- [审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [App Store 提交指南](https://developer.apple.com/app-store/submit/)

### 辅助工具
- [appletoscreenshot.com](https://appletoscreenshot.com) - 添加设备边框
- [CleanShot X](https://cleanshot.com) - 专业截图工具
- [GitHub Pages](https://pages.github.com) - 免费部署网页

---

## 💡 下一步操作

### 立即执行（今天）

1. **截取应用截图**
   ```bash
   cd AppStoreAssets
   ./capture_screenshots.sh
   ```

2. **运行应用并测试**
   ```bash
   open focus_mac.xcodeproj
   # 在 Xcode 中点击 Run (⌘R)
   ```

3. **检查证书配置**
   ```
   Xcode → Preferences → Accounts → Manage Certificates
   ```

### 明天执行

1. 部署隐私政策网页
2. 在 App Store Connect 创建应用
3. 填写所有应用信息
4. 上传构建版本

### 后天执行

1. 提交审核
2. 等待审核通过（3-5 天）
3. 准备发布宣传

---

## ⚠️ 注意事项

### 审核常见被拒原因
- ❌ 隐私政策 URL 无效
- ❌ 截图尺寸不符合要求
- ❌ 应用有 crash 或 bug
- ❌ 元数据不完整
- ❌ 功能与描述不符

### 如何避免
- ✅ 提前检查所有 URL 可访问
- ✅ 严格按照尺寸要求准备截图
- ✅ 充分测试所有功能
- ✅ 完整填写所有字段
- ✅ 确保描述准确

---

## 📊 当前进度

| 任务 | 状态 | 完成度 |
|------|------|--------|
| App 图标 | ✅ 完成 | 100% |
| 配置文件 | ✅ 完成 | 100% |
| 国际化 | ✅ 完成 | 100% |
| 法律文档 | ✅ 完成 | 100% |
| **App Store 截图** | ⏳ 进行中 | 0% |
| 证书配置 | ⏳ 待开始 | 0% |
| App Store Connect | ⏳ 待开始 | 0% |
| TestFlight 测试 | ⏳ 待开始 | 0% |

**总体进度**: 40% 完成

---

## 🎉 里程碑

- ✅ 图标生成完成（2026-06-09）
- ✅ 截图工具准备完成（2026-06-09）
- ⏳ 截图完成（目标：2026-06-10）
- ⏳ 提交审核（目标：2026-06-12）
- ⏳ 审核通过（预计：2026-06-15~17）
- ⏳ 正式发布（预计：2026-06-18）

---

**需要帮助？**

查看以下文档获取详细信息：
- `GenerateScreenshots.md` - 截图详细指南
- `Screenshot_Checklist.md` - 截图检查清单
- `Release_Checklist_发布检查清单.md` - 完整发布清单
- `README_素材清单.md` - 所有素材要求

**祝上架顺利！🚀**
