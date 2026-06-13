import Foundation
import Combine
import UserNotifications
import AppKit

/// 20-20-20 护眼提醒服务
/// 规则：每 20 分钟，看 20 英尺（约 6 米）远的地方，持续 20 秒
class EyeCareReminderService: ObservableObject {
    static let shared = EyeCareReminderService()
    
    // 配置参数
    private let workInterval: TimeInterval = 20 * 60  // 20 分钟工作
    private let restDuration: TimeInterval = 20       // 20 秒休息
    
    // 状态
    @Published var isEnabled: Bool = false
    @Published var isResting: Bool = false
    @Published var remainingWorkTime: TimeInterval = 0
    @Published var remainingRestTime: TimeInterval = 0
    
    // 计时器
    private var workTimer: Timer?
    private var restTimer: Timer?
    private var lastStartTime: Date?
    
    private init() {
        loadSettings()
    }
    
    // MARK: - 设置管理
    
    func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "eyeCareReminderEnabled")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: "eyeCareReminderEnabled")
    }
    
    // MARK: - 专注会话管理
    
    /// 开始专注会话时调用
    func startFocusSession() {
        guard isEnabled else { return }
        
        lastStartTime = Date()
        remainingWorkTime = workInterval
        startWorkTimer()
    }
    
    /// 停止专注会话时调用
    func stopFocusSession() {
        stopWorkTimer()
        stopRestTimer()
        isResting = false
        remainingWorkTime = workInterval
        remainingRestTime = 0
    }
    
    /// 暂停专注会话时调用
    func pauseFocusSession() {
        stopWorkTimer()
        stopRestTimer()
    }
    
    /// 恢复专注会话时调用
    func resumeFocusSession() {
        guard isEnabled else { return }
        
        if isResting {
            startRestTimer()
        } else {
            startWorkTimer()
        }
    }
    
    // MARK: - 工作计时器
    
    private func startWorkTimer() {
        stopWorkTimer()
        
        workTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingWorkTime -= 1
            
            if self.remainingWorkTime <= 0 {
                self.triggerRestReminder()
            }
        }
    }
    
    private func stopWorkTimer() {
        workTimer?.invalidate()
        workTimer = nil
    }
    
    // MARK: - 休息计时器
    
    private func startRestTimer() {
        stopRestTimer()
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingRestTime -= 1
            
            if self.remainingRestTime <= 0 {
                self.finishRestPeriod()
            }
        }
    }
    
    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
    }
    
    // MARK: - 提醒逻辑
    
    /// 触发休息提醒
    private func triggerRestReminder() {
        stopWorkTimer()
        isResting = true
        remainingRestTime = restDuration
        
        // 发送通知
        sendRestNotification()
        
        // 播放提示音
        playReminderSound()
        
        // 启动休息计时器
        startRestTimer()
    }
    
    /// 完成休息时段
    private func finishRestPeriod() {
        stopRestTimer()
        isResting = false
        remainingWorkTime = workInterval
        
        // 发送恢复工作通知
        sendResumeWorkNotification()
        
        // 播放提示音
        playReminderSound()
        
        // 重新启动工作计时器
        startWorkTimer()
    }
    
    // MARK: - 通知
    
    private func sendRestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "eye_care_reminder_title".localized
        content.body = "eye_care_reminder_body".localized
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "eyeCareRestReminder",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送护眼提醒通知失败: \(error)")
            }
        }
    }
    
    private func sendResumeWorkNotification() {
        let content = UNMutableNotificationContent()
        content.title = "eye_care_resume_title".localized
        content.body = "eye_care_resume_body".localized
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "eyeCareResumeReminder",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送恢复工作通知失败: \(error)")
            }
        }
    }
    
    // MARK: - 音效
    
    private func playReminderSound() {
        NSSound(named: "Glass")?.play()
    }
    
    // MARK: - 格式化
    
    /// 格式化剩余时间为 mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
