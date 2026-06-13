import Foundation
import UserNotifications
import Combine
import AppKit

/// 通知管理服务，负责请求权限、发送系统通知、播放警告音及震动
class NotificationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    private let hapticPerformer = NSHapticFeedbackManager.defaultPerformer
    
    @Published var isAuthorized: Bool = false
    
    // 自定义提示音
    private var customAlertSound: NSSound?
    private var customDrowsySound: NSSound?
    
    override init() {
        super.init()
        center.delegate = self
        checkPermission()
        loadCustomSounds()
    }
    
    /// 加载自定义提示音文件
    private func loadCustomSounds() {
        // 从 Resources/Sounds 目录加载自定义提示音 (支持 mp3 和 wav)
        if let soundURL = Bundle.main.url(forResource: "alert_triple", withExtension: "mp3", subdirectory: "Sounds") {
            customAlertSound = NSSound(contentsOf: soundURL, byReference: true)
            customAlertSound?.volume = 1.0
        } else if let soundURL = Bundle.main.url(forResource: "alert_triple", withExtension: "wav", subdirectory: "Sounds") {
            customAlertSound = NSSound(contentsOf: soundURL, byReference: true)
            customAlertSound?.volume = 1.0
        }
        
        // 瞌睡提醒使用相同的声音
        if let soundURL = Bundle.main.url(forResource: "alert_triple", withExtension: "mp3", subdirectory: "Sounds") {
            customDrowsySound = NSSound(contentsOf: soundURL, byReference: true)
            customDrowsySound?.volume = 1.0
        } else if let soundURL = Bundle.main.url(forResource: "alert_triple", withExtension: "wav", subdirectory: "Sounds") {
            customDrowsySound = NSSound(contentsOf: soundURL, byReference: true)
            customDrowsySound?.volume = 1.0
        }
    }
    
    /// 检查并请求通知权限
    func checkPermission() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    /// 发送走神提醒通知 (面部离开)
    func sendDistractionAlert(sound: Bool, haptic: Bool) {
        if sound { playAlertSound() }
        if haptic { performHapticFeedback() }
        sendNotification(
            title: "notification_distraction_title".localized,
            body: "notification_distraction_body".localized
        )
    }
    
    /// 发送瞌睡提醒通知 (闭眼)
    func sendDrowsyAlert(sound: Bool, haptic: Bool) {
        if sound { playDrowsySound() }
        if haptic { performStrongHaptic() } // 瞌睡使用更强烈的反馈
        sendNotification(
            title: "notification_drowsy_title".localized,
            body: "notification_drowsy_body".localized
        )
    }
    
    /// 发送坐姿提醒通知（渐进式）
    /// - Parameters:
    ///   - posture: 当前坐姿状态
    ///   - level: 提醒级别 (1: 温和，2: 中等，3: 强烈)
    ///   - sound: 是否播放声音
    ///   - haptic: 是否震动
    ///   - banner: 是否显示通知
    func sendPostureAlert(posture: PostureState, level: Int = 1, sound: Bool = true, haptic: Bool = true, banner: Bool = true) {
        print("[Notification] 发送坐姿提醒：级别\(level), 坐姿：\(posture.rawValue), 声音：\(sound), 震动：\(haptic), 通知：\(banner)")
        
        // 视觉反馈（菜单栏图标闪烁由 UI 层处理）
        
        // 听觉反馈：渐进式提示音
        if sound {
            switch level {
            case 1:
                playGentleSound()
            case 2:
                playModerateSound()
            default:
                playStrongSound()
            }
        }
        
        // 触觉反馈：渐进式反馈
        if haptic {
            switch level {
            case 1:
                performGentleHaptic()
            case 2:
                performModerateHaptic()
            default:
                performStrongHaptic()
            }
        }
        
        // 通知反馈
        if banner {
            let title = "notification_posture_title_format".localized(with: level)
            let body = "notification_posture_body_format".localized(with: posture.localizedName)
            print("[Notification] 发送通知：\(title) - \(body)")
            sendNotification(title: title, body: body)
        }
    }
    
    /// 播放走神警告音
    private func playAlertSound() {
        NSSound.beep()
    }
    
    /// 播放瞌睡警告音 (更强烈的提醒)
    private func playDrowsySound() {
        if let sound = NSSound(named: "Glass") {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    /// 播放温和提示音（滴）
    private func playGentleSound() {
        // 短促的单音
        if let sound = NSSound(named: "Pop") {
            sound.volume = 0.8  // 增大音量到 0.8
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    /// 播放中等提示音（滴滴）
    private func playModerateSound() {
        // 双音提示
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            if let sound = NSSound(named: "Pop") {
                sound.volume = 0.5
                sound.play()
            } else {
                NSSound.beep()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            if let sound = NSSound(named: "Pop") {
                sound.volume = 0.5
                sound.play()
            } else {
                NSSound.beep()
            }
        }
    }
    
    /// 播放强烈提示音（连续警报）
    private func playStrongSound() {
        // 优先使用自定义提示音
        if let sound = customAlertSound {
            // 连续播放三次自定义提示音
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) { [weak self] in
                    if let soundClone = self?.customAlertSound?.copy() as? NSSound {
                        soundClone.volume = 1.0
                        soundClone.play()
                    }
                }
            }
        } else {
            // 降级到系统 Pop 音
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    if let sound = NSSound(named: "Pop") {
                        sound.volume = 1.0  // 增大音量到最大 1.0
                        sound.play()
                    } else {
                        NSSound.beep()
                    }
                }
            }
        }
    }
    
    /// 执行温和触感反馈（轻微震动）
    private func performGentleHaptic() {
        // 使用 alignment 产生轻微感
        hapticPerformer.perform(.alignment, performanceTime: .now)
    }
    
    /// 执行中等触感反馈（明显震动）
    private func performModerateHaptic() {
        // 两次连续的 levelChange
        hapticPerformer.perform(.levelChange, performanceTime: .now)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.hapticPerformer.perform(.levelChange, performanceTime: .now)
        }
    }
    
    /// 执行强烈触感反馈（连续震动）
    private func performStrongHaptic() {
        // 快速连续的 5 次 generic 模拟震动感
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) { [weak self] in
                self?.hapticPerformer.perform(.generic, performanceTime: .now)
            }
        }
    }
    
    /// 执行触感反馈 (震动)
    private func performHapticFeedback() {
        // 默认反馈
        hapticPerformer.perform(.generic, performanceTime: .now)
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    // UNUserNotificationCenterDelegate: 在应用前台时也能显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
