# 📋 网站内容更新清单

## ✅ 当前状态

网站已成功部署：https://mg1988.github.io/focusguard-app/

---

## 🔧 需要更新的信息

### 1. 联系邮箱（重要 ⭐）

**当前**：
- `privacy@focusguard.app`
- `legal@focusguard.app`
- `support@focusguard.app`

**问题**：这些域名邮箱可能不存在

**建议更新为**：
- 你的实际邮箱（如：`mg1988@gmail.com`）
- 或者注册 `focusguard.app` 域名后设置转发邮箱

**需要修改的文件**：
- `privacy.html` - 第 261 行
- `terms.html` - 第 281 行
- `index.html` - 第 175 行

---

### 2. 网站 URL（重要 ⭐）

**当前**：
- `https://www.focusguard.app/privacy`
- `https://www.focusguard.app/terms`

**问题**：域名 `focusguard.app` 可能还未购买

**建议更新为**：
```
https://mg1988.github.io/focusguard-app/privacy.html
https://mg1988.github.io/focusguard-app/terms.html
```

**需要修改的文件**：
- `privacy.html` - 第 262 行
- `terms.html` - 第 282 行

---

### 3. 最后更新日期（建议更新）

**当前**：
- `2024 年 1 月 1 日`

**建议更新为**：
- `2026 年 6 月 9 日`（今天）

**需要修改的文件**：
- `privacy.html` - 第 162 行
- `terms.html` - 第 141 行

---

### 4. 版权年份（建议更新）

**当前**：
- `© 2024 FocusGuard`

**建议更新为**：
- `© 2026 FocusGuard`

**需要修改的文件**：
- `privacy.html` - 第 285 行
- `terms.html` - 第 292 行
- `index.html` - 第 179 行

---

### 5. 应用名称确认（可选）

**当前**：
- 英文名："FocusGuard"

**确认**：名称已统一为 FocusGuard

---

##  更新步骤

### 方法 1：手动编辑（推荐，可控性强）

**步骤**：

1. **在 GitHub 上直接编辑**
   ```
   访问：https://github.com/mg1988/focusguard-app
   点击要编辑的文件
   点击右上角铅笔图标
   修改后点击 "Commit changes"
   ```

2. **批量修改建议**：
   - 先修改 `privacy.html`
   - 再修改 `terms.html`
   - 最后修改 `index.html`

---

### 方法 2：本地修改后推送

**步骤**：

1. **克隆仓库（如果还没有）**
   ```bash
   cd ~
   git clone https://github.com/mg1988/focusguard-app.git
   cd focusguard-app
   ```

2. **修改文件**
   ```bash
   # 使用你喜欢的编辑器
   nano privacy.html
   nano terms.html
   nano index.html
   ```

3. **提交并推送**
   ```bash
   git add .
   git commit -m "Update contact info and dates"
   git push
   ```

---

## 🎯 具体修改内容

### 文件 1: privacy.html

**第 162 行** - 更新日期：
```html
<!-- 原内容 -->
<p class="subtitle">最后更新日期：2024 年 1 月 1 日</p>

<!-- 修改为 -->
<p class="subtitle">最后更新日期：2026 年 6 月 9 日</p>
```

**第 261-262 行** - 联系方式：
```html
<!-- 原内容 -->
<li><strong>电子邮件</strong>: privacy@focusguard.app</li>
<li><strong>网站</strong>: https://www.focusguard.app/privacy</li>

<!-- 修改为 -->
<li><strong>电子邮件</strong>: mg1988@gmail.com</li>
<li><strong>网站</strong>: https://mg1988.github.io/focusguard-app/privacy.html</li>
```

**第 285 行** - 版权年份：
```html
<!-- 原内容 -->
<p>© 2024 FocusGuard. All rights reserved.</p>

<!-- 修改为 -->
<p>© 2026 FocusGuard. All rights reserved.</p>
```

---

### 文件 2: terms.html

**第 141 行** - 更新日期：
```html
<!-- 原内容 -->
<p class="subtitle">最后更新日期：2024 年 1 月 1 日</p>

<!-- 修改为 -->
<p class="subtitle">最后更新日期：2026 年 6 月 9 日</p>
```

**第 281-282 行** - 联系方式：
```html
<!-- 原内容 -->
<li><strong>电子邮件</strong>: legal@focusguard.app</li>
<li><strong>网站</strong>: https://www.focusguard.app/terms</li>

<!-- 修改为 -->
<li><strong>电子邮件</strong>: mg1988@gmail.com</li>
<li><strong>网站</strong>: https://mg1988.github.io/focusguard-app/terms.html</li>
```

**第 292 行** - 版权年份：
```html
<!-- 原内容 -->
<p>© 2024 FocusGuard. All rights reserved.</p>

<!-- 修改为 -->
<p>© 2026 FocusGuard. All rights reserved.</p>
```

---

### 文件 3: index.html

**第 175 行** - 联系邮箱：
```html
<!-- 原内容 -->
<a href="mailto:support@focusguard.app">联系支持</a>

<!-- 修改为 -->
<a href="mailto:mg1988@gmail.com">联系支持</a>
```

**第 179 行** - 版权年份：
```html
<!-- 原内容 -->
<p>© 2024 FocusGuard. All rights reserved.</p>

<!-- 修改为 -->
<p>© 2026 FocusGuard. All rights reserved.</p>
```

---

##  快速更新方案（最简单）

### 使用 GitHub 网页编辑器

**步骤**：

1. **访问仓库**
   ```
   https://github.com/mg1988/focusguard-app
   ```

2. **编辑 privacy.html**
   - 点击 `privacy.html` 文件
   - 点击右上角铅笔图标 ️
   - 按 `Cmd + F` 搜索并替换：
     - `2024 年 1 月 1 日` → `2026 年 6 月 9 日`
     - `privacy@focusguard.app` → `mg1988@gmail.com`
     - `https://www.focusguard.app/privacy` → `https://mg1988.github.io/focusguard-app/privacy.html`
     - `© 2024` → `© 2026`
   - 滚动到底部，输入提交信息：`Update contact info and dates`
   - 点击 "Commit changes"

3. **重复步骤 2** 编辑 `terms.html` 和 `index.html`

4. **等待部署**
   - 2-3 分钟后自动更新
   - 刷新页面查看效果

---

## ✅ 更新后验证

### 检查清单

更新完成后，逐项检查：

- [ ] 所有日期已更新为 2026 年
- [ ] 联系邮箱改为你的实际邮箱
- [ ] 网站 URL 改为 GitHub Pages URL
- [ ] 版权年份更新为 2026
- [ ] 所有链接可以点击
- [ ] 页面显示正常
- [ ] 移动端显示正常

### 测试 URL

访问以下 URL 验证更新：

**首页**：
```
https://mg1988.github.io/focusguard-app/
```

**隐私政策**：
```
https://mg1988.github.io/focusguard-app/privacy.html
```

**使用条款**：
```
https://mg1988.github.io/focusguard-app/terms.html
```

---

## 📊 其他可选优化

### 1. 添加实际的应用截图

**当前**：首页只有 emoji 图标

**可以添加**：应用实际截图

**步骤**：
```
1. 截取应用界面图
2. 上传到 GitHub 仓库
3. 在 index.html 中添加 <img> 标签
```

### 2. 添加下载链接

**当前**：只有 "Available on the App Store" 文字

**可以添加**：App Store 下载按钮

**步骤**：
```
1. 下载 App Store Badge
2. 上传到仓库
3. 在 index.html 中添加链接
```

### 3. 添加 favicon

**当前**：没有网站图标

**可以添加**：使用应用图标

**步骤**：
```
1. 准备 32x32 的 PNG 图标
2. 上传到仓库，命名为 favicon.png
3. 在每个 HTML 的 <head> 中添加：
   <link rel="icon" href="favicon.png">
```

---

## 🎯 建议优先级

### 必须更新（影响上架）⭐⭐⭐

1. **联系邮箱** - App Store 审核需要有效邮箱
2. **网站 URL** - 确保链接可访问
3. **日期** - 保持文档时效性

### 建议更新（提升专业度）⭐⭐

1. **版权年份** - 显示维护状态
2. **应用名称统一** - 品牌一致性

### 可选优化（锦上添花）⭐

1. **应用截图** - 更直观展示
2. **下载按钮** - 方便用户
3. **网站图标** - 更专业

---

## 💡 邮箱建议

### 方案 A：使用个人邮箱（最简单）

```
mg1988@gmail.com
mg1988@163.com
mg1988@qq.com
```

**优点**：
- ✅ 立即可用
- ✅ 无需额外配置
- ✅ 免费

**缺点**：
-  不够专业

### 方案 B：注册域名邮箱（推荐）

**步骤**：

1. **购买域名**
   ```
   访问：https://www.namecheap.com/
   搜索：focusguard.app（或其他）
   价格：约 $10-15/年
   ```

2. **设置邮箱转发**
   ```
   使用：ForwardEmail.net（免费）
   或：Zoho Mail（免费计划）
   
   设置：
   support@focusguard.app → mg1988@gmail.com
   privacy@focusguard.app → mg1988@gmail.com
   legal@focusguard.app → mg1988@gmail.com
   ```

3. **更新网站**
   ```
   将邮箱改为域名邮箱
   ```

**优点**：
- ✅ 专业
- ✅ 品牌一致
- ✅ 可自定义

**缺点**：
- ❌ 需要付费买域名
- ❌ 需要配置 DNS

---

## 📋 立即行动清单

### 第一步：更新基本信息（5 分钟）

1. **打开 GitHub 仓库**
   ```
   https://github.com/mg1988/focusguard-app
   ```

2. **编辑 privacy.html**
   - 更新日期：2026 年 6 月 9 日
   - 更新邮箱：mg1988@gmail.com
   - 更新 URL：https://mg1988.github.io/focusguard-app/privacy.html
   - 更新版权：© 2026

3. **编辑 terms.html**（同上）

4. **编辑 index.html**（同上）

### 第二步：验证更新（2 分钟）

1. **等待部署**（2-3 分钟）
2. **刷新页面**
3. **检查所有链接**

### 第三步：准备提交 App Store（下一步）

更新完成后，就可以：
1. 登录 App Store Connect
2. 创建应用
3. 填写隐私政策 URL

---

## 🚀 现在开始吧！

**推荐先用 GitHub 网页编辑器快速更新**：

1. 访问：https://github.com/mg1988/focusguard-app
2. 点击 `privacy.html`
3. 点铅笔图标编辑
4. 搜索并替换关键信息
5. 提交保存
6. 重复步骤 2-5 处理其他文件
7. 等待部署完成

**完成后告诉我**，我会帮你验证更新，然后就可以准备提交 App Store 审核了！🎉
