import SwiftUI

/// FocusGuard 应用主入口，适配 macOS 菜单栏常驻模式
@main
struct focus_macApp: App {
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            MainView(viewModel: viewModel)
        } label: {
            HStack {
                DynamicMenuBarIcon(
                    progress: viewModel.progress,
                    status: viewModel.status,
                    remainingTime: viewModel.remainingTime,
                    focusTime: viewModel.focusTime,
                    isGoalActive: viewModel.isGoalActive,
                    timerMode: viewModel.timerMode,
                    currentPosture: viewModel.currentPosture,
                    isPostureAlertActive: viewModel.isPostureAlertEnabled && viewModel.currentPosture != .good && viewModel.status == .active
                )
                // 增加一个隐藏的文字标签，有助于系统分配菜单栏空间
                Text("Focus").opacity(0)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
