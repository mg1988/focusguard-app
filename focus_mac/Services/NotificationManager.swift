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
    
    override init() {
        super.init()
        center.delegate = self
        checkPermission()
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
            title: NSLocalizedString("notification_distraction_title", comment: "Focus Alert"),
            body: NSLocalizedString("notification_distraction_body", comment: "Get back to work!")
        )
    }
    
    /// 发送瞌睡提醒通知 (闭眼)
    func sendDrowsyAlert(sound: Bool, haptic: Bool) {
        if sound { playDrowsySound() }
        if haptic { performHapticFeedback() }
        sendNotification(
            title: NSLocalizedString("notification_drowsy_title", comment: "Drowsy Alert"),
            body: NSLocalizedString("notification_drowsy_body", comment: "Wake up!")
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
                print("[Notification] 播放温和提示音")
                playGentleSound()  // 温和提示音
            case 2:
                print("[Notification] 播放中等提示音")
                playModerateSound()  // 中等提示音
            default:
                print("[Notification] 播放强烈提示音")
                playStrongSound()  // 强烈提示音
            }
        }
        
        // 触觉反馈：渐进式震动
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
            let title = String(format: NSLocalizedString("notification_posture_title_format", comment: ""), level)
            let body = String(format: NSLocalizedString("notification_posture_body_format", comment: ""), posture.localizedName)
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
            sound.volume = 0.3
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
    
    /// 播放强烈提示音（连续）
    private func playStrongSound() {
        // 连续三音提示
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                if let sound = NSSound(named: "Pop") {
                    sound.volume = 0.7
                    sound.play()
                } else {
                    NSSound.beep()
                }
            }
        }
    }
    
    /// 执行温和触感反馈（轻微震动）
    private func performGentleHaptic() {
        hapticPerformer.perform(.alignment, performanceTime: .now)
    }
    
    /// 执行中等触感反馈（明显震动）
    private func performModerateHaptic() {
        hapticPerformer.perform(.levelChange, performanceTime: .now)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.hapticPerformer.perform(.levelChange, performanceTime: .now)
        }
    }
    
    /// 执行强烈触感反馈（连续震动）
    private func performStrongHaptic() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) { [weak self] in
                self?.hapticPerformer.perform(.generic, performanceTime: .now)
            }
        }
    }
    
    /// 执行触感反馈 (震动)
    private func performHapticFeedback() {
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
