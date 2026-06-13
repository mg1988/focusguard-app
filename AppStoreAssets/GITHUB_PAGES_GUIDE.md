#  GitHub Pages 部署完整指南

## ✅ 已准备文件

以下文件已创建在 `AppStoreAssets/` 目录：

```
AppStoreAssets/
├── index.html              # 首页
├── privacy.html            # 隐私政策
├── terms.html              # 使用条款
├── README.md               # 说明文档
├── deploy_github_pages.sh  # 自动部署脚本
└── GITHUB_PAGES_GUIDE.md   # 本指南
```

---

## 方法 1：使用自动部署脚本（推荐 ⭐ 最简单）

### 步骤：

**1. 运行部署脚本**
```bash
cd /Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets
./deploy_github_pages.sh
```

**2. 按提示操作**
- 输入你的 GitHub 用户名
- 输入 GitHub Personal Access Token
- 脚本会自动创建仓库并部署

**3. 获取 Token**
- 访问：https://github.com/settings/tokens
- 点击 "Generate new token (classic)"
- 勾选权限：`repo` (Full control of private repositories)
- 点击 "Generate token"
- 复制 Token（只显示一次）

**4. 等待部署**
- 脚本会自动推送代码
- 等待 1-2 分钟
- GitHub Pages 会自动部署

**5. 访问网站**
```
https://YOUR_USERNAME.github.io/focusguard-web/
```

---

## 方法 2：手动部署（更可控）

### 步骤 1：创建 GitHub 仓库

1. **访问** https://github.com/new
2. **仓库名称**: `focusguard-web`
3. **可见性**: 公开（Public）
4. **描述**: FocusGuard Privacy Policy Website
5. **点击** "Create repository"

### 步骤 2：上传文件

```bash
# 进入目录
cd /Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets

# 初始化 Git
git init

# 添加文件
git add index.html privacy.html terms.html README.md

# 提交
git commit -m "Initial commit: FocusGuard privacy policy website"

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/focusguard-web.git

# 推送
git branch -M main
git push -u origin main
```

### 步骤 3：启用 GitHub Pages

1. **访问** https://github.com/YOUR_USERNAME/focusguard-web/settings/pages
2. **Source**: 选择 "Deploy from a branch"
3. **Branch**: 选择 "main"
4. **Folder**: 选择 "/ (root)"
5. **点击** "Save"

### 步骤 4：等待部署

- GitHub 会自动部署（1-2 分钟）
- 刷新页面查看部署状态
- 成功后会显示你的网站地址

---

## 方法 3：使用 GitHub Desktop（最简单 GUI）

### 步骤：

**1. 下载 GitHub Desktop**
- 访问：https://desktop.github.com/
- 下载并安装

**2. 登录 GitHub**
- 打开 GitHub Desktop
- 使用 GitHub 账号登录

**3. 创建仓库**
- File → New Repository
- 名称：`focusguard-web`
- 选择位置：`AppStoreAssets` 文件夹
- 点击 "Create repository"

**4. 添加文件**
- 将 HTML 文件拖入文件夹
- GitHub Desktop 会自动检测

**5. 提交并推送**
- 输入提交信息："Initial commit"
- 点击 "Commit"
- 点击 "Publish repository"

**6. 启用 Pages**
- 访问仓库设置
- 启用 GitHub Pages（同方法 2）

---

## 验证部署

### 检查部署状态

1. **访问**: https://github.com/YOUR_USERNAME/focusguard-web/deployments
2. **查看**: github-pages 部署状态
3. **状态**: 应该是 "Active"

### 测试页面

访问以下 URL 验证：

**首页**:
```
https://YOUR_USERNAME.github.io/focusguard-web/
```

**隐私政策**:
```
https://YOUR_USERNAME.github.io/focusguard-web/privacy.html
```

**使用条款**:
```
https://YOUR_USERNAME.github.io/focusguard-web/terms.html
```

---

## 自定义域名（可选）

### 步骤：

**1. 购买域名**
- 推荐：Namecheap, GoDaddy, Cloudflare
- 例如：`focusguard.app`

**2. 配置 GitHub Pages**
- 访问：https://github.com/YOUR_USERNAME/focusguard-web/settings/pages
- Custom domain: 输入你的域名
- 点击 "Save"

**3. 配置 DNS**

在域名提供商处添加：

**A 记录**（4 条）:
```
@ → 185.199.108.153
@ → 185.199.109.153
@ → 185.199.110.153
@ → 185.199.111.153
```

**CNAME 记录**（可选）:
```
www → YOUR_USERNAME.github.io
```

**4. 启用 HTTPS**
- 等待 DNS 传播（最多 24 小时）
- 在 GitHub Pages 设置中勾选 "Enforce HTTPS"

---

## 更新网站内容

### 方法：

**1. 修改 HTML 文件**
```bash
# 编辑文件
nano privacy.html
# 或使用你喜欢的编辑器
```

**2. 提交更改**
```bash
cd /Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets
git add .
git commit -m "Update privacy policy"
git push
```

**3. 自动部署**
- GitHub 会自动检测更改
- 等待 1-2 分钟
- 网站会自动更新

---

## 常见问题

### Q1: 页面显示 404

**原因**: GitHub Pages 还未部署完成

**解决**:
- 等待 1-2 分钟
- 刷新页面
- 检查部署状态：https://github.com/YOUR_USERNAME/focusguard-web/actions

### Q2: 样式不显示

**原因**: CSS 文件路径错误

**解决**:
- 确保使用相对路径
- 检查文件是否在正确位置
- 清除浏览器缓存

### Q3: 推送失败

**原因**: 认证问题

**解决**:
```bash
# 清除缓存的凭证
git credential-osxkeychain erase

# 重新推送
git push
```

### Q4: 仓库已存在

**解决**:
- 使用不同的仓库名称
- 或删除现有仓库重新创建

---

## 快速参考

### 部署命令速查

```bash
# 初始化
git init
git add .
git commit -m "Initial commit"

# 添加远程
git remote add origin https://github.com/YOUR_USERNAME/focusguard-web.git

# 推送
git branch -M main
git push -u origin main
```

### 更新命令速查

```bash
git add .
git commit -m "Update description"
git push
```

### 重要链接

- **GitHub Pages 设置**: https://github.com/YOUR_USERNAME/focusguard-web/settings/pages
- **部署历史**: https://github.com/YOUR_USERNAME/focusguard-web/deployments
- **GitHub Actions**: https://github.com/YOUR_USERNAME/focusguard-web/actions

---

## 完成检查清单

部署完成后，逐项检查：

- [ ] GitHub 仓库已创建
- [ ] 所有 HTML 文件已上传
- [ ] GitHub Pages 已启用
- [ ] 网站可以访问
- [ ] 首页加载正常
- [ ] 隐私政策页面正常
- [ ] 使用条款页面正常
- [ ] 所有链接可以点击
- [ ] 移动端显示正常

---

## 下一步

网站部署完成后：

1. **复制隐私政策 URL**
   ```
   https://YOUR_USERNAME.github.io/focusguard-web/privacy.html
   ```

2. **复制使用条款 URL**
   ```
   https://YOUR_USERNAME.github.io/focusguard-web/terms.html
   ```

3. **准备提交 App Store**
   - 登录 App Store Connect
   - 创建应用
   - 填写隐私政策和使用条款 URL

---

## 💡 提示

- GitHub Pages 完全免费
- 无需续费
- 自动 HTTPS
- 全球 CDN 加速
- 每月 100GB 免费流量

---

**现在选择你喜欢的方法开始部署吧！** 🚀

推荐使用自动脚本（方法 1）或 GitHub Desktop（方法 3），最简单快速！
