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
