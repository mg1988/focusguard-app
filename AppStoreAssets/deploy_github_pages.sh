#!/bin/bash

# FocusGuard GitHub Pages 部署脚本
# 自动部署隐私政策网站到 GitHub Pages

echo " FocusGuard GitHub Pages 部署助手"
echo "=================================="
echo ""

# 检查 Git 是否安装
if ! command -v git &> /dev/null; then
    echo "❌ 错误：未检测到 Git"
    echo "请先安装 Git: brew install git"
    exit 1
fi

echo "✅ Git 已安装"

# 获取 GitHub 用户名
echo ""
echo "请输入你的 GitHub 用户名："
read -p "> " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ 错误：用户名不能为空"
    exit 1
fi

echo "✅ GitHub 用户名：$GITHUB_USERNAME"

# 检查是否已登录 GitHub
echo ""
echo "检查 GitHub 登录状态..."

# 尝试使用 gh CLI（如果已安装）
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "✅ 已登录 GitHub"
    else
        echo "⚠️  未登录 GitHub"
        echo "请选择登录方式："
        echo "1) 使用 gh auth login (推荐)"
        echo "2) 使用 HTTPS + 密码/Token"
        read -p "选择 (1/2): " AUTH_METHOD
        
        if [ "$AUTH_METHOD" = "1" ]; then
            echo "运行：gh auth login"
            gh auth login
        else
            echo "️  请确保你有 GitHub Personal Access Token"
        fi
    fi
else
    echo "ℹ️  GitHub CLI (gh) 未安装，将使用 HTTPS 方式"
    echo "提示：安装 gh 可以简化认证：brew install gh"
fi

# 创建临时目录
TEMP_DIR="/tmp/focusguard-web-deploy"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo ""
echo "📦 准备部署文件..."

# 复制文件
cp index.html privacy.html terms.html README.md "$TEMP_DIR/"

cd "$TEMP_DIR"

# 初始化 Git 仓库
echo ""
echo " 初始化 Git 仓库..."
git init
git add .
git commit -m "Initial commit: FocusGuard privacy policy website"

# 创建远程仓库（使用 GitHub API）
echo ""
echo "🌐 创建 GitHub 仓库..."

# 提示用户输入 Token
echo "请输入 GitHub Personal Access Token:"
echo "获取方式：https://github.com/settings/tokens"
echo "需要的权限：repo"
read -sp "> " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误：Token 不能为空"
    exit 1
fi

# 创建仓库
RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"focusguard-web\",\"public\":true,\"description\":\"FocusGuard Privacy Policy Website\"}" \
    https://api.github.com/user/repos)

# 检查是否创建成功
if echo "$RESPONSE" | grep -q "\"full_name\""; then
    echo "✅ 仓库创建成功"
    REPO_URL="https://github.com/$GITHUB_USERNAME/focusguard-web.git"
else
    echo "⚠️  仓库可能已存在或创建失败"
    echo "响应：$RESPONSE"
    echo ""
    echo "如果仓库已存在，请输入仓库 URL:"
    read -p "> " REPO_URL
fi

# 添加远程仓库
git remote add origin "$REPO_URL"

# 推送
echo ""
echo "📤 推送到 GitHub..."
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================="
    echo "✅ 部署成功！"
    echo "=================================="
    echo ""
    echo "🌐 你的网站将在 1-2 分钟后上线："
    echo "   https://$GITHUB_USERNAME.github.io/focusguard-web/"
    echo ""
    echo "📄 页面地址："
    echo "   首页：https://$GITHUB_USERNAME.github.io/focusguard-web/"
    echo "   隐私政策：https://$GITHUB_USERNAME.github.io/focusguard-web/privacy.html"
    echo "   使用条款：https://$GITHUB_USERNAME.github.io/focusguard-web/terms.html"
    echo ""
    echo "⚙️  下一步："
    echo "   1. 访问 https://github.com/$GITHUB_USERNAME/focusguard-web/settings/pages"
    echo "   2. 确认 Pages 已启用（Branch: main, Folder: / (root)）"
    echo "   3. 等待 1-2 分钟部署完成"
    echo ""
else
    echo ""
    echo "❌ 推送失败"
    echo "请检查："
    echo "   1. GitHub 用户名是否正确"
    echo "   2. Token 是否有效"
    echo "   3. 仓库是否已存在"
    echo ""
    echo "手动推送步骤："
    echo "   cd $TEMP_DIR"
    echo "   git remote add origin <你的仓库 URL>"
    echo "   git push -u origin main"
fi

echo ""
echo "💡 提示：以后更新只需："
echo "   git add ."
echo "   git commit -m \"Update\""
echo "   git push"
echo ""
