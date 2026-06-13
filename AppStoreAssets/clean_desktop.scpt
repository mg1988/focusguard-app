-- 隐藏桌面图标和文件的 AppleScript
tell application "Finder"
    set desktop picture to POSIX file "/System/Library/Desktop Pictures/Uniform Color/Gray.png"
end tell

-- 隐藏桌面图标
do shell script "defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
