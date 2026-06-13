# FocusGuard 隐私政策网站

这是 FocusGuard macOS 应用的官方隐私政策和使用条款网站。

## 文件结构

```
focusguard-web/
── index.html      # 首页
├── privacy.html    # 隐私政策
├── terms.html      # 使用条款
└── README.md       # 说明文档
```

## 部署到 GitHub Pages

### 步骤 1: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称：`focusguard-web`
3. 可见性：公开（Public）
4. 点击 "Create repository"

### 步骤 2: 上传文件

```bash
# 初始化 Git
cd /Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets

# 初始化仓库
git init

# 添加所有文件
git add index.html privacy.html terms.html README.md

# 提交
git commit -m "Initial commit: FocusGuard privacy policy website"

# 添加远程仓库（替换 YOUR_USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/focusguard-web.git

# 推送
git branch -M main
git push -u origin main
```

### 步骤 3: 启用 GitHub Pages

1. 进入仓库的 Settings 页面
2. 左侧菜单选择 "Pages"
3. Source 选择 "Deploy from a branch"
4. Branch 选择 "main"，文件夹选择 "/ (root)"
5. 点击 "Save"

### 步骤 4: 获取网址

等待 1-2 分钟，GitHub Pages 将自动部署。

你的网站地址将是：
```
https://YOUR_USERNAME.github.io/focusguard-web/
```

具体页面：
- 首页：https://YOUR_USERNAME.github.io/focusguard-web/
- 隐私政策：https://YOUR_USERNAME.github.io/focusguard-web/privacy.html
- 使用条款：https://YOUR_USERNAME.github.io/focusguard-web/terms.html

## 自定义域名（可选）

如果想使用自定义域名（如 focusguard.app）：

1. 购买域名（如在 Namecheap、GoDaddy）
2. 在 GitHub Pages 设置中添加自定义域名
3. 在域名提供商处配置 DNS：
   - A 记录指向：185.199.108.153
   - CNAME 记录：YOUR_USERNAME.github.io

## 更新内容

修改 HTML 文件后：

```bash
git add .
git commit -m "Update privacy policy"
git push
```

GitHub Pages 会在几分钟内自动更新。

## 许可证

© 2024 FocusGuard. All rights reserved.
