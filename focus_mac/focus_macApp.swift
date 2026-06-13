import SwiftUI
import AppKit

/// FocusGuard 应用主入口，保持 MenuBarExtra 逻辑，增加右键菜单
@main
struct focus_macApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            MainView(viewModel: viewModel)
        } label: {
            DynamicMenuBarIcon(
                progress: viewModel.progress,
                status: viewModel.status,
                remainingTime: viewModel.remainingTime,
                focusTime: viewModel.focusTime,
                isGoalActive: viewModel.isGoalActive,
                timerMode: viewModel.timerMode,
                currentPosture: viewModel.currentPosture,
                isPostureAlertActive: viewModel.isPostureAlertEnabled && viewModel.currentPosture != .good && viewModel.status == .active,
                customIconName: "menuIcon"
            )
        }
        .menuBarExtraStyle(.window)
    }
}

/// 应用代理，负责启动时应用主题和设置右键菜单
class AppDelegate: NSObject, NSApplicationDelegate {
    private var rightClickMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动时立即应用保存的主题
        ThemeManager.shared.applyTheme()
        
        // 延迟设置右键菜单，等待 MenuBarExtra 创建完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupRightClickMenu()
        }
    }
    
    /// 设置右键菜单
    private func setupRightClickMenu() {
        // 查找菜单栏中的状态栏按钮
        guard let button = findMenuBarButton() else { return }
        
        // 创建右键菜单
        let menu = NSMenu()
        
        // 开启/停止专注
        let focusItem = NSMenuItem(title: "menu_start_focus".localized, action: #selector(toggleFocus(_:)), keyEquivalent: "")
        focusItem.target = self
        menu.addItem(focusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 关于
        let aboutItem = NSMenuItem(title: "menu_about".localized, action: #selector(showAbout(_:)), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // 退出
        let quitItem = NSMenuItem(title: "menu_quit".localized, action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // 监听右键点击
        rightClickMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            if event.window == button.window {
                let location = NSEvent.mouseLocation
                menu.popUp(positioning: nil, at: location, in: nil)
                return nil // 阻止事件继续传播
            }
            return event
        }
    }
    
    /// 查找菜单栏按钮
    private func findMenuBarButton() -> NSStatusBarButton? {
        // 遍历所有状态栏项，找到我们的图标
        for window in NSApplication.shared.windows {
            if let contentView = window.contentView {
                for subview in contentView.subviews {
                    if let button = subview as? NSStatusBarButton {
                        return button
                    }
                }
            }
        }
        return nil
    }
    
    /// 切换专注模式
    @objc private func toggleFocus(_ sender: NSMenuItem) {
        FocusViewModel.shared.toggleFocusMode()
        // 更新菜单标题
        sender.title = FocusViewModel.shared.status == .idle ? "menu_start_focus".localized : "menu_stop_focus".localized
    }
    
    /// 显示关于对话框
    @objc private func showAbout(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "app_name".localized
        alert.informativeText = "about_description".localized + "\n\n" + "version_info".localized
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    /// 退出应用
    @objc private func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = rightClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
