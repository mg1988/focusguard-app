import Foundation
import Combine

/// 应用支持的语言列表
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "System"        // 跟随系统
    case english = "en"           // 英语
    case chineseSimplified = "zh-Hans"  // 简体中文
    case japanese = "ja"          // 日语
    case korean = "ko"            // 韩语
    case german = "de"            // 德语
    case french = "fr"            // 法语
    case italian = "it"           // 意大利语
    case spanish = "es"           // 西班牙语
    case portugueseBR = "pt-BR"   // 葡萄牙语 - 巴西
    case russian = "ru"           // 俄语
    case arabic = "ar"            // 阿拉伯语
    
    var id: String { self.rawValue }
    
    /// 语言的本地化名称（用于在 UI 中显示）
    var localizedName: String {
        let bundle = BundleLanguageHelper.getBundle()
        switch self {
        case .system:
            return bundle.localizedString(forKey: "language_system", value: "System", table: nil)
        case .english:
            return "English"
        case .chineseSimplified:
            return "简体中文"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        case .italian:
            return "Italiano"
        case .spanish:
            return "Español"
        case .portugueseBR:
            return "Português (Brasil)"
        case .russian:
            return "Русский"
        case .arabic:
            return "العربية"
        }
    }
    
    /// 对应的 Locale 标识符
    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        default:
            return self.rawValue
        }
    }
}

/// 语言管理器 - 负责应用语言的切换
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private let selectedLanguageKey = "selected_language"
    
    @Published var currentLanguage: AppLanguage = .system
    
    init() {
        // 从 UserDefaults 加载已保存的语言设置
        if let savedLanguageCode = UserDefaults.standard.string(forKey: selectedLanguageKey) {
            self.currentLanguage = AppLanguage(rawValue: savedLanguageCode) ?? .system
        }
        
        // 应用语言设置
        applyLanguage(currentLanguage)
    }
    
    /// 切换应用语言
    func setLanguage(_ language: AppLanguage) {
        guard currentLanguage != language else { return }
        currentLanguage = language
        
        // 保存用户选择
        UserDefaults.standard.set(language.localeIdentifier, forKey: selectedLanguageKey)
        
        // 应用语言设置
        applyLanguage(language)
        
        // 通知应用刷新 UI
        NotificationCenter.default.post(name: NSNotification.Name("LanguageDidChange"), object: nil)
    }
    
    /// 应用语言设置
    private func applyLanguage(_ language: AppLanguage) {
        guard let localeIdentifier = language.localeIdentifier else {
            // 如果是跟随系统，则重置为默认
            BundleLanguageHelper.setLanguage(nil)
            return
        }
        
        BundleLanguageHelper.setLanguage(localeIdentifier)
    }
}

/// 语言切换帮助类 - 使用关联对象实现动态语言切换
class BundleLanguageHelper {
    static func setLanguage(_ language: String?) {
        if let language = language,
           let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.main, "bundleLanguage", bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            objc_setAssociatedObject(Bundle.main, "bundleLanguage", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func getBundle() -> Bundle {
        if let languageBundle = objc_getAssociatedObject(Bundle.main, "bundleLanguage") as? Bundle {
            return languageBundle
        }
        return Bundle.main
    }
}
