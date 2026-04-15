import SwiftUI

/// FocusGuard 应用主入口，适配 macOS 菜单栏常驻模式
@main
struct focus_macApp: App {
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
                isPostureAlertActive: viewModel.isPostureAlertEnabled && viewModel.currentPosture != .good && viewModel.status == .active
            )
        }
        .menuBarExtraStyle(.window)
    }
}
