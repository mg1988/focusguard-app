# FocusGuard GitHub 部署指南

## ✅ 已创建的文件

所有文件都位于 `AppStoreAssets/` 目录：

### 📄 HTML 页面文件
1. **index.html** - 主页（精美的落地页）
2. **privacy.html** - 隐私政策页面
3. **terms.html** - 使用条款页面

### 📖 文档文件
4. **README_GitHub_Pages.md** - GitHub Pages 部署教程
5. **README_素材清单.md** - App Store 素材准备指南
6. **Privacy_Policy_隐私政策.md** - 隐私政策原文（Markdown）
7. **Terms_of_Use_使用条款.md** - 使用条款原文（Markdown）
8. **Release_Checklist_发布检查清单.md** - 发布检查清单
9. **GITHUB_DEPLOYMENT.md** - 本文件

---

## 🚀 快速部署步骤

### 第一步：创建 GitHub 仓库

1. 访问 [GitHub](https://github.com)
2. 创建新仓库，命名为 `focusguard-app`（或其他名称）
3. 设为公开仓库（Public）

### 第二步：上传文件

将以下 HTML 文件上传到仓库根目录：

```bash
cd /Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets

# 上传到 GitHub（使用 Git 或网页上传）
git init
git remote add origin https://github.com/yourusername/focusguard-app.git
git add index.html privacy.html terms.html
git commit -m "Initial commit: FocusGuard legal pages"
git push -u origin main
```

### 第三步：启用 GitHub Pages

1. 进入仓库 → **Settings** → **Pages**
2. Source 选择：
   - Branch: `main`
   - Folder: `/ (root)`
3. 点击 **Save**

### 第四步：获取 URL

等待 1-2 分钟后，你的页面将上线：

```
主页：https://yourusername.github.io/focusguard-app/
隐私政策：https://yourusername.github.io/focusguard-app/privacy.html
使用条款：https://yourusername.github.io/focusguard-app/terms.html
```

---

## 📋 在 Apple 系统中使用

### 更新 Info.plist

将隐私政策 URL 更新为你的 GitHub Pages URL：

```xml
<key>NSPrivacyPolicyURL</key>
<string>https://yourusername.github.io/focusguard-app/privacy.html</string>
```

### App Store Connect 配置

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择 FocusGuard 应用
3. 填写以下字段：

**隐私政策 URL**:
```
https://yourusername.github.io/focusguard-app/privacy.html
```

**技术支持 URL**:
```
https://yourusername.github.io/focusguard-app/
```

**营销 URL**（可选）:
```
https://yourusername.github.io/focusguard-app/
```

---

## 🎨 页面预览

### 主页 (index.html)
- ✅ 渐变色背景
- ✅ 应用 Logo 展示
- ✅ 核心功能列表
- ✅ 隐私政策和使用条款链接
- ✅ GitHub 仓库链接
- ✅ App Store 下载按钮
- ✅ 响应式设计

### 隐私政策 (privacy.html)
- ✅ Apple 风格设计
- ✅ 清晰的章节结构
- ✅ 重点内容高亮显示
- ✅ 隐私承诺清单
- ✅ 联系方式

### 使用条款 (terms.html)
- ✅ 专业法律文档格式
- ✅ 分章节详细说明
- ✅ 重要提示醒目标注
- ✅ 响应式布局

---

## ⚙️ 自定义配置

### 修改联系方式

在所有 HTML 文件中替换：

```
yourusername → 你的 GitHub 用户名
support@focusguard.app → 你的支持邮箱
legal@focusguard.app → 法律联系邮箱
```

### 修改品牌色

在 HTML 文件中找到 CSS 部分，修改渐变色：

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

改为你喜欢的颜色组合。

### 添加自定义域名

1. 购买域名（如 focusguard.app）
2. 在 GitHub Pages 设置中添加自定义域名
3. 配置 DNS CNAME 记录
4. 在仓库根目录创建 `CNAME` 文件

---

## ✅ 部署验证清单

- [ ] 所有 HTML 文件已上传到 GitHub
- [ ] GitHub Pages 已启用
- [ ] 主页可以正常访问
- [ ] 隐私政策页面可以正常访问
- [ ] 使用条款页面可以正常访问
- [ ] 页面在手机上显示正常
- [ ] 所有链接都可以点击
- [ ] 联系方式已更新
- [ ] URL 已填写到 App Store Connect

---

## 🔗 示例 URL

假设你的 GitHub 用户名是 `mg-dev`，仓库名是 `focusguard-app`：

```
主页：https://mg-dev.github.io/focusguard-app/
隐私政策：https://mg-dev.github.io/focusguard-app/privacy.html
使用条款：https://mg-dev.github.io/focusguard-app/terms.html
```

---

## 💡 高级选项

### 使用自定义域名

如果你购买了域名（如 `focusguard.app`）：

1. 在域名服务商添加 CNAME 记录：
   ```
   Type: CNAME
   Name: www
   Value: mg-dev.github.io
   ```

2. 在仓库根目录创建 `CNAME` 文件：
   ```
   focusguard.app
   ```

3. 在 GitHub Pages 设置中添加自定义域名

访问 URL 变为：
```
https://focusguard.app/privacy.html
https://focusguard.app/terms.html
```

### 添加分析（可选）

在 HTML 文件的 `<head>` 部分添加 Google Analytics 或其他分析工具。

---

## 📱 二维码生成（可选）

为隐私政策 URL 生成二维码，放在应用官网或文档中：

使用在线工具：
- [QR Code Generator](https://www.qr-code-generator.com/)
- [Google Chart API](https://developers.google.com/chart/infographics/docs/qr_codes)

---

## 🆘 常见问题

### Q: GitHub Pages 多久能上线？
A: 通常 1-2 分钟，最长不超过 10 分钟。

### Q: 可以删除仓库重新创建吗？
A: 可以，但需要重新配置 GitHub Pages。

### Q: 需要备案吗？
A: GitHub Pages 使用国外服务器，不需要备案。

### Q: 可以商用吗？
A: 可以，GitHub Pages 允许商业用途。

### Q: 有流量限制吗？
A: GitHub Pages 有每月 100GB 流量限制，对于法律页面完全够用。

---

## 📞 技术支持

如有问题，请通过以下方式联系：

- **Email**: support@focusguard.app
- **GitHub Issues**: [github.com/yourusername/focus_mac/issues](https://github.com/yourusername/focus_mac/issues)

---

## 📚 相关资源

- [GitHub Pages 官方文档](https://docs.github.com/en/pages)
- [App Store Connect 帮助](https://developer.apple.com/app-store-connect/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

---

**祝你部署顺利！🎉**

---

**文档版本**: 1.0  
**最后更新**: 2024 年 1 月  
**维护者**: FocusGuard 团队
