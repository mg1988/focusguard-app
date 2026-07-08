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
        // 尝试从 Sounds 子目录加载，如果找不到则从 Bundle 根目录加载
        let soundURL = Bundle.main.url(forResource: "alert_triple", withExtension: "mp3", subdirectory: "Sounds")
            ?? Bundle.main.url(forResource: "alert_triple", withExtension: "mp3")
        
        if let url = soundURL {
            customAlertSound = NSSound(contentsOf: url, byReference: true)
            customAlertSound?.volume = 1.0
            customDrowsySound = NSSound(contentsOf: url, byReference: true)
            customDrowsySound?.volume = 1.0
            #if DEBUG
            print("[Notification] 成功加载自定义警告音：\(url.path)")
            #endif
        } else {
            #if DEBUG
            print("[Notification] 警告：无法找到 alert_triple.mp3 文件")
            #endif
        }
    }
    
    /// 检查并请求通知权限
    func checkPermission() {
        // 先获取当前权限状态
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                #if DEBUG
                print("[Notification] 当前权限状态：\(settings.authorizationStatus.rawValue) (0=notDetermined, 1=denied, 2=authorized, 3=provisional)")
                #endif
            }
        }
        
        // 请求权限
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                #if DEBUG
                print("[Notification] 权限请求结果：\(granted ? "已授权" : "被拒绝")")
                if let error = error {
                    print("[Notification] 权限请求错误：\(error)")
                }
                #endif
            }
            
            // 请求后再次获取最新状态
            self.center.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.isAuthorized = settings.authorizationStatus == .authorized
                    #if DEBUG
                    print("[Notification] 请求后权限状态：\(settings.authorizationStatus.rawValue)")
                    #endif
                }
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
        #if DEBUG
        print("[Notification] 发送坐姿提醒：级别\(level), 坐姿：\(posture.rawValue), 声音：\(sound), 震动：\(haptic), 通知：\(banner)")
        #endif
        
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
            #if DEBUG
            print("[Notification] 发送通知：\(title) - \(body)")
            #endif
            sendNotification(title: title, body: body)
        }
    }
    
    /// 播放走神警告音（使用自定义 alert_triple.mp3）
    private func playAlertSound() {
        if let sound = customAlertSound {
            sound.currentTime = 0
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    /// 播放瞌睡警告音（使用自定义 alert_triple.mp3，连续三次，更强烈的提醒）
    private func playDrowsySound() {
        if let sound = customDrowsySound {
            // 连续播放三次自定义提示音，提供更强烈的提醒
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) { [weak self] in
                    if let s = self?.customDrowsySound {
                        s.volume = 1.0
                        s.currentTime = 0
                        s.play()
                    }
                }
            }
        } else {
            NSSound.beep()
        }
    }
    
    /// 播放温和提示音（使用自定义 alert_triple.mp3）
    private func playGentleSound() {
        if let sound = customAlertSound {
            sound.volume = 0.8
            sound.currentTime = 0
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    /// 播放中等提示音（使用自定义 alert_triple.mp3，双音）
    private func playModerateSound() {
        if let sound = customAlertSound {
            sound.volume = 0.5
            sound.currentTime = 0
            sound.play()
        } else {
            NSSound.beep()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            if let sound = self?.customAlertSound {
                sound.volume = 0.5
                sound.currentTime = 0
                sound.play()
            } else {
                NSSound.beep()
            }
        }
    }
    
    /// 播放强烈提示音（使用自定义 alert_triple.mp3，连续三次）
    private func playStrongSound() {
        if let sound = customAlertSound {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) { [weak self] in
                    if let s = self?.customAlertSound {
                        s.volume = 1.0
                        s.currentTime = 0
                        s.play()
                    }
                }
            }
        } else {
            NSSound.beep()
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
    
    /// 发送本地通知（使用自定义 alert_triple.mp3 声音）
    func sendNotification(title: String, body: String) {
        // 检查权限
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            let authorized = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                self.isAuthorized = authorized
            }
            
            guard authorized else {
                #if DEBUG
                print("[Notification] 警告：通知权限未授权 (status: \(settings.authorizationStatus.rawValue))，无法发送通知")
                #endif
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            // 使用自定义声音 alert_triple.mp3（直接在 Resources 目录）
            content.sound = UNNotificationSound(named: UNNotificationSoundName("alert_triple.mp3"))
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            self.center.add(request) { error in
                #if DEBUG
                if let error = error {
                    print("[Notification] 发送通知失败：\(error)")
                } else {
                    print("[Notification] 通知已发送：\(title) - \(body)")
                }
                #endif
            }
        }
    }
    
    // UNUserNotificationCenterDelegate: 在应用前台时也能显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // macOS 13+ 需要 .list 选项才能在通知中心显示
        // .banner: 显示横幅，.sound: 播放声音，.list: 在通知中心显示
        if #available(macOS 13.0, *) {
            completionHandler([.banner, .sound, .list])
        } else {
            completionHandler([.banner, .sound])
        }
    }
}
