#!/bin/bash

# FocusGuard App Store 截图辅助脚本
# 用法：./capture_screenshots.sh

echo "📸 FocusGuard App Store 截图助手"
echo "================================"
echo ""

# 创建截图保存目录
SCREENSHOT_DIR="$HOME/Desktop/FocusGuard_Screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "✅ 截图保存目录：$SCREENSHOT_DIR"
echo ""

# 检查 Xcode 是否安装
if ! command -v xcrun &> /dev/null; then
    echo "❌ 未检测到 Xcode，请先安装 Xcode"
    exit 1
fi

echo "💡 使用说明："
echo ""
echo "方法 1: 使用 Xcode 模拟器（推荐）"
echo "  1. 在 Xcode 中运行应用到 Mac 模拟器"
echo "  2. 在模拟器中按 ⌘S 截图"
echo "  3. 截图会自动保存到桌面"
echo ""
echo "方法 2: 使用 macOS 原生截图"
echo "  - 截取窗口：⌘ + ⇧ + 4 + 空格，然后点击窗口"
echo "  - 截取区域：⌘ + ⇧ + 4，然后选择区域"
echo "  - 截取全屏：⌘ + ⇧ + 3"
echo ""
echo "方法 3: 使用此脚本调整尺寸"
echo ""

# 询问用户是否需要调整现有截图尺寸
read -p "是否需要调整已有截图的尺寸？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "请选择目标尺寸："
    echo "1. MacBook Pro 13\" (2880 x 1800)"
    echo "2. iPad Pro 12.9\" (2048 x 2732)"
    echo "3. 自定义尺寸"
    echo ""
    read -p "选择 (1/2/3): " size_choice
    
    case $size_choice in
        1)
            TARGET_WIDTH=2880
            TARGET_HEIGHT=1800
            echo "✓ 目标尺寸：MacBook Pro 13\" (2880 x 1800)"
            ;;
        2)
            TARGET_WIDTH=2048
            TARGET_HEIGHT=2732
            echo "✓ 目标尺寸：iPad Pro 12.9\" (2048 x 2732)"
            ;;
        3)
            read -p "输入宽度 (像素): " TARGET_WIDTH
            read -p "输入高度 (像素): " TARGET_HEIGHT
            echo "✓ 目标尺寸：${TARGET_WIDTH} x ${TARGET_HEIGHT}"
            ;;
        *)
            echo "❌ 无效选择"
            exit 1
            ;;
    esac
    
    echo ""
    read -p "输入截图文件路径 (直接回车使用默认目录): " input_path
    
    if [ -z "$input_path" ]; then
        input_path="$SCREENSHOT_DIR"
    fi
    
    echo ""
    echo "📐 开始调整尺寸..."
    
    # 处理目录中的所有 PNG 文件
    for file in "$input_path"/*.png; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            output_file="$SCREENSHOT_DIR/resized_${filename}"
            
            echo "  处理：$filename"
            
            # 使用 sips 调整尺寸
            sips -z $TARGET_HEIGHT $TARGET_WIDTH "$file" --out "$output_file" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "    ✅ 已保存：resized_${filename}"
            else
                echo "    ❌ 失败：$filename"
            fi
        fi
    done
    
    echo ""
    echo "✅ 尺寸调整完成！"
    echo "📁 输出目录：$SCREENSHOT_DIR"
fi

echo ""
echo "🎯 截图内容建议："
echo ""
echo "必需截图（至少 2 张）："
echo "  1. 主界面 - 专注模式（显示计时器和状态）"
echo "  2. 统计数据页面（7 天历史记录）"
echo ""
echo "推荐截图："
echo "  3. 抓拍相册功能"
echo "  4. 坐姿检测提醒"
echo "  5. 设置页面（多语言和隐私）"
echo ""

echo "📋 下一步操作："
echo "  1. 运行应用并切换到各个页面"
echo "  2. 使用 ⌘ + ⇧ + 4 + 空格 截取窗口"
echo "  3. 如有需要，运行此脚本调整尺寸"
echo "  4. 将截图上传到 App Store Connect"
echo ""
echo "💡 提示：截图应清晰展示核心功能，避免模糊或遮挡"
echo ""
echo "================================"
echo "祝截图顺利！📸"
echo ""
