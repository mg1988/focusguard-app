import SwiftUI

/// FocusGuard 应用主入口，适配 macOS 菜单栏常驻模式
@main
struct focus_macApp: App {
    // 禁用窗口模式 (LSUIElement) 的情况下，MenuBarExtra 是主要交互入口
    var body: some Scene {
        // 使用 MenuBarExtra 在系统状态栏显示应用图标
        MenuBarExtra("FocusGuard", systemImage: "timer") {
            // 在菜单项中直接展示主视图 (macOS 13+)
            MainView()
        }
        .menuBarExtraStyle(.window) // 设置为窗口风格，点击图标弹出界面
    }
}
