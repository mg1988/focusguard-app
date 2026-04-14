import Foundation
import AppIntents

/// 定义专注模式过滤器，让系统专注模式开启时通知应用
struct FocusGuardFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("FocusGuard 联动")
    static var description = IntentDescription(LocalizedStringResource("当此系统专注模式开启时，FocusGuard 将自动进入对应的检测状态。"))
    
    @Parameter(title: "自动开始专注", default: true)
    var shouldStartFocus: Bool

    var displayRepresentation: DisplayRepresentation {
        if shouldStartFocus {
            return DisplayRepresentation(title: "FocusGuard 联动", subtitle: "自动开启专注")
        } else {
            return DisplayRepresentation(title: "FocusGuard 联动", subtitle: "不自动开启")
        }
    }

    func perform() async throws -> some IntentResult {
        // 当过滤器激活时调用
        let start = shouldStartFocus
        DispatchQueue.main.async {
            if start {
                NotificationCenter.default.post(name: .startFocusFromIntent, object: nil)
            }
        }
        return .result()
    }
}

/// 为系统提供“开始专注”的操作
struct StartFocusIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("开始 FocusGuard 专注")
    static var description = IntentDescription(LocalizedStringResource("启动 FocusGuard 专注会话。"))

    static var parameterSummary: some ParameterSummary {
        Summary("开始专注")
    }

    func perform() async throws -> some IntentResult {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .startFocusFromIntent, object: nil)
        }
        return .result()
    }
}

/// 为系统提供“停止专注”的操作
struct StopFocusIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("停止 FocusGuard 专注")
    static var description = IntentDescription(LocalizedStringResource("停止当前的 FocusGuard 专注会话。"))

    static var parameterSummary: some ParameterSummary {
        Summary("停止专注")
    }
    
    func perform() async throws -> some IntentResult {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .stopFocusFromIntent, object: nil)
        }
        return .result()
    }
}

/// 定义通知名称扩展
extension Notification.Name {
    static let startFocusFromIntent = Notification.Name("startFocusFromIntent")
    static let stopFocusFromIntent = Notification.Name("stopFocusFromIntent")
}

/// 快捷指令短语注册
struct FocusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: [
                "开始 \(.applicationName) 专注",
                "在 \(.applicationName) 中开始工作"
            ],
            shortTitle: LocalizedStringResource("开始专注"),
            systemImageName: "timer"
        )
    }
}
