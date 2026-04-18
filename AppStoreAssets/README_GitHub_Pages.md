# GitHub Pages 部署指南

本目录包含 FocusGuard 应用的隐私政策和使用条款的 HTML 页面，可以通过 GitHub Pages 免费托管。

## 📁 文件说明

- `privacy.html` - 隐私政策页面
- `terms.html` - 使用条款页面
- `README_GitHub_Pages.md` - 本部署指南

## 🚀 部署步骤

### 方法一：使用 GitHub Pages（推荐）

#### 1. 创建 GitHub 仓库

1. 登录 GitHub
2. 创建新仓库，例如：`focusguard-app`
3. 仓库设为公开（Public）

#### 2. 上传文件

将以下文件上传到仓库根目录：
- `privacy.html`
- `terms.html`

#### 3. 启用 GitHub Pages

1. 进入仓库 **Settings** → **Pages**
2. 在 **Source** 下选择：
   - Branch: `main` (或 `master`)
   - Folder: `/ (root)`
3. 点击 **Save**

#### 4. 访问页面

等待 1-2 分钟，GitHub Pages 将自动部署。

访问地址格式：
```
https://yourusername.github.io/focusguard-app/privacy.html
https://yourusername.github.io/focusguard-app/terms.html
```

### 方法二：使用自定义域名（可选）

1. 在 **Settings** → **Pages** → **Custom domain** 中添加你的域名
2. 配置 DNS：
   ```
   Type: CNAME
   Name: www (或 @)
   Value: yourusername.github.io
   ```
3. 在仓库根目录创建 `CNAME` 文件，内容为你的域名：
   ```
   focusguard.app
   ```

访问地址：
```
https://focusguard.app/privacy.html
https://focusguard.app/terms.html
```

## 🔗 在 App Store Connect 中使用

将生成的 URL 填写到 App Store Connect：

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择你的 App
3. 在 **App 信息** 页面填写：
   - **隐私政策 URL**: `https://yourusername.github.io/focusguard-app/privacy.html`
   - **技术支持 URL**: `https://yourusername.github.io/focusguard-app/`（或你的官网）

## 📝 自定义内容

### 修改联系方式

在 HTML 文件中搜索并替换以下内容：

- `privacy@focusguard.app` - 隐私联系邮箱
- `legal@focusguard.app` - 法律联系邮箱
- `github.com/yourusername/focus_mac` - GitHub 仓库地址

### 修改样式

HTML 文件使用了 Apple 风格的设计，你可以自定义 CSS：

```html
<style>
    /* 修改主色调 */
    h1 {
        border-bottom-color: #0071e3; /* 改为你的品牌色 */
    }
    
    .highlight {
        border-left-color: #0071e3; /* 改为你的品牌色 */
    }
</style>
```

## ✅ 验证部署

1. 访问隐私政策 URL，确认页面正常显示
2. 访问使用条款 URL，确认页面正常显示
3. 检查所有链接是否有效
4. 在移动设备上测试响应式显示

## 🎨 页面特性

- ✅ 响应式设计，适配所有设备
- ✅ Apple 风格 UI，简洁专业
- ✅ 无需维护，GitHub 自动托管
- ✅ HTTPS 加密，安全可靠
- ✅ 加载速度快
- ✅ SEO 友好

## 📊 示例 URL

部署成功后，你的 URL 应该是：

```
https://yourusername.github.io/focusguard-app/privacy.html
https://yourusername.github.io/focusguard-app/terms.html
```

例如：
```
https://mg-dev.github.io/focusguard-app/privacy.html
https://mg-dev.github.io/focusguard-app/terms.html
```

## ⚠️ 注意事项

1. **仓库名称**：建议使用 `focusguard-app` 或类似名称，避免与主代码仓库冲突
2. **隐私政策**：确保内容真实反映应用的数据处理实践
3. **定期更新**：如隐私政策有更新，记得同步更新 HTML 文件
4. **备份**：保留原始 Markdown 文档作为备份

## 🆘 故障排除

### GitHub Pages 不显示

1. 检查仓库是否为公开（Public）
2. 检查是否正确启用 GitHub Pages
3. 等待 1-2 分钟让 GitHub 完成部署
4. 刷新页面或清除缓存

### 页面样式异常

1. 确保 HTML 文件完整上传
2. 检查浏览器控制台是否有错误
3. 尝试在其他浏览器中打开

### URL 访问 404

1. 确认文件名正确（`privacy.html`, `terms.html`）
2. 确认 GitHub Pages 已正确配置
3. 等待 GitHub 完成部署（可能需要几分钟）

## 📚 相关资源

- [GitHub Pages 官方文档](https://docs.github.com/en/pages)
- [App Store Connect 帮助](https://developer.apple.com/app-store-connect/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

---

**祝你部署顺利！** 🎉

如有问题，请通过以下方式联系：
- Email: support@focusguard.app
- GitHub: [github.com/yourusername/focus_mac](https://github.com/yourusername/focus_mac)
