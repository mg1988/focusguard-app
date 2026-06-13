import SwiftUI
import AppKit
import Combine

/// 应用主题枚举
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .system: return "theme_system".localized
        case .light: return "theme_light".localized
        case .dark: return "theme_dark".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
    
    /// 获取对应的 NSAppearance
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        }
    }
    
    /// 保存到 UserDefaults
    func save() {
        UserDefaults.standard.set(rawValue, forKey: "app_theme")
    }
    
    /// 从 UserDefaults 加载保存的主题
    static func loadSaved() -> AppTheme {
        if let saved = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: saved) {
            return theme
        }
        return .system
    }
}

/// 主题管理器 - 负责全局应用主题
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system
    
    private init() {
        currentTheme = AppTheme.loadSaved()
        applyTheme()
    }
    
    /// 设置并应用主题
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        theme.save()
        applyTheme()
    }
    
    /// 将主题应用到所有窗口
    func applyTheme() {
        let appearance = currentTheme.nsAppearance
        
        // 应用到所有已存在的窗口
        for window in NSApplication.shared.windows {
            window.appearance = appearance
        }
        
        // 同时设置应用级别的外观（影响后续创建的窗口）
        NSApplication.shared.appearance = appearance
    }
}
