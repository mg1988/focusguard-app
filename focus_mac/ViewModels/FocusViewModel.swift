import Foundation
import Combine
import SwiftUI

/// 专注状态枚举，定义专注应用的不同运行状态
enum FocusStatus {
    case idle           // 待命
    case active         // 专注中
    case distracted     // 走神中
}

/// 灵敏度枚举，定义不同判定走神的时间阈值
enum Sensitivity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var distractionThreshold: TimeInterval {
        switch self {
        case .low: return 5.0
        case .medium: return 3.0
        case .high: return 1.0
        }
    }
    
    var localizedName: String {
        switch self {
        case .low: return NSLocalizedString("sensitivity_low", comment: "")
        case .medium: return NSLocalizedString("sensitivity_medium", comment: "")
        case .high: return NSLocalizedString("sensitivity_high", comment: "")
        }
    }
}

/// 核心业务逻辑 ViewModel，驱动 UI 变化并协调底层服务
class FocusViewModel: ObservableObject {
    // 状态属性
    @Published var status: FocusStatus = .idle
    @Published var focusTime: TimeInterval = 0
    @Published var distractionCount: Int = 0
    @Published var drowsyCount: Int = 0 // 瞌睡统计
    @Published var sensitivity: Sensitivity = .medium
    @Published var isFaceDetected: Bool = false
    @Published var isEyesClosed: Bool = false // 眼睛状态
    
    // 设置属性
    @Published var isSoundEnabled: Bool = true
    @Published var isHapticEnabled: Bool = true
    @Published var drowsyThreshold: Double = 2.0 // 瞌睡判定秒数
    
    // 历史数据
    @Published var history: [DailyStats] = []
    
    // 计时器相关
    private var mainTimer: Timer?
    private var distractionTimer: Timer?
    private var drowsyTimer: Timer? // 瞌睡计时器
    private var distractionStartTime: Date?
    private var drowsyStartTime: Date? // 瞌睡开始时间
    
    // 底层服务引用
    private let faceManager = FaceDetectionManager.shared
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // 格式化输出
    var formattedFocusTime: String {
        let hours = Int(focusTime) / 3600
        let minutes = (Int(focusTime) % 3600) / 60
        let seconds = Int(focusTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    init() {
        loadDailyStats()
        bindFaceDetection()
    }
    
    /// 绑定 FaceDetectionManager 的检测结果
    private func bindFaceDetection() {
        faceManager.$isFaceDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detected in
                self?.isFaceDetected = detected
                self?.handleFaceDetectionUpdate(detected)
            }
            .store(in: &cancellables)
            
        faceManager.$isEyesClosed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] closed in
                self?.isEyesClosed = closed
                self?.handleDrowsyUpdate(closed)
            }
            .store(in: &cancellables)
    }
    
    /// 开启/关闭专注模式切换逻辑
    func toggleFocusMode() {
        if status == .idle {
            startFocusSession()
        } else {
            stopFocusSession()
        }
    }
    
    /// 开启专注会话
    private func startFocusSession() {
        status = .active
        faceManager.startDetection()
        startMainTimer()
    }
    
    /// 停止专注会话并持久化数据
    private func stopFocusSession() {
        status = .idle
        faceManager.stopDetection()
        mainTimer?.invalidate()
        mainTimer = nil
        distractionTimer?.invalidate()
        distractionTimer = nil
        saveDailyStats()
    }
    
    /// 处理面部检测状态变更 (走神判定)
    private func handleFaceDetectionUpdate(_ detected: Bool) {
        guard status != .idle else { return }
        
        if detected {
            // 如果恢复面部，则重置走神计时
            distractionTimer?.invalidate()
            distractionTimer = nil
            distractionStartTime = nil
            if !isEyesClosed { status = .active }
        } else {
            // 如果面部丢失且不在走神计时中，则开始计时
            if distractionStartTime == nil {
                distractionStartTime = Date()
                status = .distracted
                startDistractionTimer()
            }
        }
    }
    
    /// 处理眼睛状态变更 (瞌睡判定)
    private func handleDrowsyUpdate(_ closed: Bool) {
        guard status != .idle && isFaceDetected else { return }
        
        if !closed {
            // 睁眼，重置瞌睡计时
            drowsyTimer?.invalidate()
            drowsyTimer = nil
            drowsyStartTime = nil
            status = .active
        } else {
            // 闭眼，开始计时
            if drowsyStartTime == nil {
                drowsyStartTime = Date()
                startDrowsyTimer()
            }
        }
    }
    
    /// 启动主计时器 (累加专注时间)
    private func startMainTimer() {
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.status != .idle else { return }
            self.focusTime += 1
            // 每分钟自动保存一次
            if Int(self.focusTime) % 60 == 0 {
                self.saveDailyStats()
            }
        }
    }
    
    /// 启动走神判定计时器
    private func startDistractionTimer() {
        distractionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.distractionStartTime else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= self.sensitivity.distractionThreshold {
                // 触发走神提醒
                self.distractionCount += 1
                self.notificationManager.sendDistractionAlert(
                    sound: self.isSoundEnabled,
                    haptic: self.isHapticEnabled
                )
                self.distractionStartTime = nil // 重置计时，避免重复触发
                timer.invalidate()
                self.saveDailyStats()
            }
        }
    }
    
    /// 启动瞌睡判定计时器
    private func startDrowsyTimer() {
        drowsyTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.drowsyStartTime else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed >= self.drowsyThreshold {
                // 触发走神提醒
                self.drowsyCount += 1
                self.notificationManager.sendDrowsyAlert(
                    sound: self.isSoundEnabled,
                    haptic: self.isHapticEnabled
                )
                self.drowsyStartTime = nil
                timer.invalidate()
                self.saveDailyStats()
            }
        }
    }
    
    // MARK: - 数据持久化
    
    private func loadDailyStats() {
        // 加载设置
        self.isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled") 
        if UserDefaults.standard.object(forKey: "isSoundEnabled") == nil { self.isSoundEnabled = true }
        
        self.isHapticEnabled = UserDefaults.standard.bool(forKey: "isHapticEnabled")
        if UserDefaults.standard.object(forKey: "isHapticEnabled") == nil { self.isHapticEnabled = true }
        
        self.drowsyThreshold = UserDefaults.standard.double(forKey: "drowsyThreshold")
        if self.drowsyThreshold == 0 { self.drowsyThreshold = 2.0 }

        // 加载历史数据
        if let data = UserDefaults.standard.data(forKey: "FocusGuardHistory"),
           let decoded = try? JSONDecoder().decode([DailyStats].self, from: data) {
            self.history = decoded
        }
        
        // 获取今日数据
        let todayStr = getTodayString()
        if let today = history.first(where: { $0.date == todayStr }) {
            self.focusTime = today.focusTime
            self.distractionCount = today.distractionCount
            self.drowsyCount = today.drowsyCount
        }
    }
    
    private func saveDailyStats() {
        // 保存设置
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled")
        UserDefaults.standard.set(drowsyThreshold, forKey: "drowsyThreshold")

        // 保存统计数据
        let todayStr = getTodayString()
        if let index = history.firstIndex(where: { $0.date == todayStr }) {
            history[index].focusTime = focusTime
            history[index].distractionCount = distractionCount
            history[index].drowsyCount = drowsyCount
        } else {
            let newDay = DailyStats(date: todayStr, focusTime: focusTime, distractionCount: distractionCount, drowsyCount: drowsyCount)
            history.insert(newDay, at: 0)
            // 仅保留最近 30 天
            if history.count > 30 { history.removeLast() }
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "FocusGuardHistory")
        }
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// 获取过去 7 天的统计摘要
    var last7DaysStats: (totalTime: TimeInterval, avgDistraction: Double, avgDrowsy: Double) {
        let last7 = Array(history.prefix(7))
        guard !last7.isEmpty else { return (0, 0, 0) }
        
        let totalTime = last7.reduce(0) { $0 + $1.focusTime }
        let totalDist = last7.reduce(0) { $0 + Double($1.distractionCount) }
        let totalDrowsy = last7.reduce(0) { $0 + Double($1.drowsyCount) }
        
        return (totalTime, totalDist / Double(last7.count), totalDrowsy / Double(last7.count))
    }
}
