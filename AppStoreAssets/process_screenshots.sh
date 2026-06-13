#!/bin/bash

# FocusGuard 截图处理脚本
# 自动调整尺寸并添加背景

echo "📸 FocusGuard 截图处理器"
echo "========================"
echo ""

# 检查是否有参数
if [ $# -eq 0 ]; then
    echo "用法：./process_screenshots.sh <截图文件1> [截图文件2] [截图文件3]"
    echo ""
    echo "例如:"
    echo "./process_screenshots.sh ~/Desktop/Screenshot\\ 2026-06-09\\ at\\ 21.30.00.png"
    echo ""
    echo "或直接拖拽截图文件到此脚本上"
    exit 1
fi

# 输出目录
OUTPUT_DIR="/Users/genweimi/Desktop/flutter/ios/focus/focus_mac/AppStoreAssets/Screenshots"
mkdir -p "$OUTPUT_DIR"

echo "✅ 输出目录：$OUTPUT_DIR"
echo ""

# 处理每个文件
counter=1
for file in "$@"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📐 处理第 $counter 张截图：$filename"
        
        # 使用 sips 调整尺寸到 MacBook Pro 13" (2880x1800)
        # 保持比例，添加白色背景
        
        # 方法：先调整到最大宽度 2880，高度自动计算
        # 然后创建白色背景并合成
        
        # 获取原图尺寸
        orig_width=$(sips -g pixelWidth "$file" | grep pixelWidth | awk '{print $2}')
        orig_height=$(sips -g pixelHeight "$file" | grep pixelHeight | awk '{print $2}')
        
        echo "   原图尺寸：${orig_width} x ${orig_height}"
        
        # 计算缩放比例（以宽度 2880 为基准）
        scale=$(echo "scale=2; 2880 / $orig_width" | bc)
        new_height=$(echo "scale=0; $orig_height * $scale / 1" | bc)
        
        echo "   缩放后高度：$new_height"
        
        # 临时文件：调整后的截图
        temp_file="/tmp/resized_screenshot.png"
        
        # 调整尺寸
        sips -z $new_height 2880 "$file" --out "$temp_file" >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "   ✅ 尺寸调整完成"
            
            # 使用 ImageMagick 添加背景（如果已安装）
            if command -v convert &> /dev/null; then
                output_file="$OUTPUT_DIR/Screenshot_$(printf "%02d" $counter)_MacBookPro.png"
                
                convert -size 2880x1800 xc:'#F5F5F5' \
                    "$temp_file" \
                    -gravity center \
                    -composite \
                    "$output_file"
                
                echo "   ✅ 已添加背景并保存"
                echo "   📁 输出：$output_file"
            else
                # 没有 ImageMagick，直接保存调整后的图
                output_file="$OUTPUT_DIR/Screenshot_$(printf "%02d" $counter)_resized.png"
                cp "$temp_file" "$output_file"
                
                echo "   ⚠️  未检测到 ImageMagick，仅调整尺寸"
                echo "   📁 输出：$output_file"
                echo ""
                echo "   💡 提示：安装 ImageMagick 以获得更好的效果"
                echo "      brew install imagemagick"
            fi
            
            # 清理临时文件
            rm -f "$temp_file"
        else
            echo "   ❌ 调整尺寸失败"
        fi
        
        echo ""
        ((counter++))
    else
        echo "⚠️  文件不存在：$file"
        echo ""
    fi
done

echo "========================"
echo "✅ 处理完成！"
echo ""
echo "📁 输出目录：$OUTPUT_DIR"
echo ""
echo "下一步："
echo "1. 检查输出的截图"
echo "2. 上传到 App Store Connect"
echo ""
