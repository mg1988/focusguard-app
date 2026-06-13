#!/bin/bash

# 一键清理桌面脚本
# 用于 App Store 截图前快速清理桌面

echo "🧹 开始清理桌面..."
echo ""

# 1. 创建临时文件夹
TEMP_DIR="$HOME/Desktop/Desktop_Temp_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

echo "✅ 创建临时文件夹：$TEMP_DIR"

# 2. 移动桌面文件到临时文件夹（排除文件夹）
echo "📦 移动桌面文件..."
for file in "$HOME"/Desktop/*; do
    filename=$(basename "$file")
    # 排除 .DS_Store 和刚创建的临时文件夹
    if [ "$filename" != ".DS_Store" ] && [ "$filename" != "Desktop_Temp_"* ]; then
        mv "$file" "$TEMP_DIR/"
        echo "   移动：$filename"
    fi
done

echo "✅ 桌面文件已清理"

# 3. 隐藏桌面图标
echo "🙈 隐藏桌面图标..."
defaults write com.apple.finder CreateDesktop -bool false
killall Finder

echo "✅ 桌面图标已隐藏"

# 4. 设置纯色壁纸（如果有权限）
echo "🎨 设置灰色壁纸..."
# 注意：设置壁纸需要 AppleScript，这里只提示
echo "💡 提示：请手动设置壁纸"
echo "   系统设置 → 墙纸 → Uniform Color → Gray"

echo ""
echo "========================"
echo "✅ 桌面清理完成！"
echo ""
echo "📁 文件已保存到：$TEMP_DIR"
echo ""
echo "恢复桌面的方法："
echo "1. 显示桌面图标："
echo "   defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
echo ""
echo "2. 移动文件回桌面："
echo "   从 $TEMP_DIR 拖回文件"
echo ""
echo "========================"
echo ""
echo "现在可以开始截图了！📸"
