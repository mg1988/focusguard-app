import Foundation
import Combine
import SwiftUI
import ServiceManagement
import AVFoundation

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
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    // 设置属性
    @Published var isSoundEnabled: Bool = true
    @Published var isHapticEnabled: Bool = true
    @Published var drowsyThreshold: Double = 2.0 // 瞌睡判定秒数
    @Published var isDoNotDisturbEnabled: Bool = false // 免打扰模式
    @Published var isLaunchAtLoginEnabled: Bool = false // 开机自启动
    
    // 历史数据
    @Published var history: [DailyStats] = []
    
    // 抓拍照片数据
    @Published var snapshots: [DistractionSnapshot] = []
    @Published var isSnapshotEnabled: Bool = true // 是否启用抓拍功能
    
    // 坐姿检测数据
    @Published var currentPosture: PostureState = .good
    @Published var isPostureDetectionEnabled: Bool = true
    @Published var postureStats: PostureStats = PostureStats()
    
    // 坐姿提醒配置
    @Published var isPostureAlertEnabled: Bool = true  // 是否启用坐姿提醒
    @Published var isPostureSoundEnabled: Bool = true  // 坐姿提醒声音
    @Published var isPostureHapticEnabled: Bool = true // 坐姿提醒震动
    @Published var isPostureBannerEnabled: Bool = true // 坐姿通知横幅
    
    // 坐姿提醒计时器
    private var badPostureStartTime: Date?
    private var badPostureTimer: Timer?
    private var currentAlertLevel: Int = 0  // 当前提醒级别 (0: 无提醒，1-3: 渐进级别)
    
    // 进度属性用于动态图标
    @Published var progress: Double = 0.0
    
    // 专注目标相关
    @Published var focusGoal: TimeInterval = 25 * 60 // 默认 25 分钟
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published var isGoalActive: Bool = false
    @Published var timerMode: Int = 0 // 0: 正向计时, 1: 倒计时
    
    // 效率评分 (0-100)
    var efficiencyScore: Int {
        let totalInterruptionPenalty = Double(distractionCount * 30 + drowsyCount * 60)
        guard focusTime > 0 else { return 0 }
        let score = (focusTime / (focusTime + totalInterruptionPenalty)) * 100
        return Int(min(max(score, 0), 100))
    }
    
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
        
        faceManager.$cameraPermissionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.cameraPermissionStatus = status
            }
            .store(in: &cancellables)
        
        // 绑定坐姿检测
        faceManager.$currentPosture
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posture in
                self?.currentPosture = posture
                self?.updatePostureStats(posture: posture)
                self?.handlePostureUpdate(posture: posture)  // 处理坐姿提醒
            }
            .store(in: &cancellables)
        
        // 同步坐姿检测开关状态
        faceManager.$isPostureDetectionEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.isPostureDetectionEnabled = enabled
                self?.faceManager.isPostureDetectionEnabled = enabled
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
        isGoalActive = false
        faceManager.stopDetection()
        mainTimer?.invalidate()
        mainTimer = nil
        distractionTimer?.invalidate()
        distractionTimer = nil
        saveDailyStats()
    }
    
    /// 专注目标达成处理
    private func handleGoalReached() {
        stopFocusSession()
        notificationManager.sendNotification(
            title: NSLocalizedString("goal_reached_title", comment: ""),
            body: NSLocalizedString("goal_reached_body", comment: "")
        )
        // 播放成功音效
        if isSoundEnabled {
            NSSound(named: "Glass")?.play()
        }
    }
    
    /// 处理面部检测状态变更 (走神判定)
    private func handleFaceDetectionUpdate(_ detected: Bool) {
        guard status != .idle else { return }
        
        // 检查免打扰模式：如果开启且检测到全屏应用，则不触发逻辑
        if isDoNotDisturbEnabled && isAnyAppFullScreen() {
            return
        }
        
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
    
    /// 执行走神抓拍
    func takeDistractionSnapshot(sampleBuffer: CMSampleBuffer?, duration: TimeInterval) {
        guard isSnapshotEnabled,
              let sampleBuffer = sampleBuffer,
              let imagePath = faceManager.captureSnapshot(from: sampleBuffer, type: .distraction, duration: duration) else {
            return
        }
        
        let snapshot = DistractionSnapshot(
            type: .distraction,
            imagePath: imagePath,
            duration: duration
        )
        
        snapshots.insert(snapshot, at: 0)
        saveSnapshots()
        print("走神抓拍成功：\(imagePath)")
    }
    
    /// 执行瞌睡抓拍
    func takeDrowsySnapshot(sampleBuffer: CMSampleBuffer?, duration: TimeInterval) {
        guard isSnapshotEnabled,
              let sampleBuffer = sampleBuffer,
              let imagePath = faceManager.captureSnapshot(from: sampleBuffer, type: .drowsy, duration: duration) else {
            return
        }
        
        let snapshot = DistractionSnapshot(
            type: .drowsy,
            imagePath: imagePath,
            duration: duration
        )
        
        snapshots.insert(snapshot, at: 0)
        saveSnapshots()
        print("瞌睡抓拍成功：\(imagePath)")
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
    
    /// 更新坐姿统计数据
    private func updatePostureStats(posture: PostureState) {
        switch posture {
        case .good:
            postureStats.goodPostureCount += 1
        case .slouching:
            postureStats.badPostureCount += 1
            postureStats.slouchingCount += 1
        case .leaning:
            postureStats.badPostureCount += 1
            postureStats.leaningCount += 1
        case .tooClose, .tooFar:
            postureStats.badPostureCount += 1
            postureStats.distanceWarningCount += 1
        }
    }
    
    /// 处理坐姿更新，触发渐进式提醒
    private func handlePostureUpdate(posture: PostureState) {
        // 打印调试信息
        print("[PostureAlert] 当前坐姿：\(posture.rawValue), 专注状态：\(status), 是否启用检测：\(isPostureDetectionEnabled), 是否启用提醒：\(isPostureAlertEnabled)")
        
        guard status != .idle && isPostureDetectionEnabled && isPostureAlertEnabled else {
            // 重置提醒状态
            if badPostureTimer != nil {
                print("[PostureAlert] 重置提醒状态")
            }
            badPostureStartTime = nil
            badPostureTimer?.invalidate()
            badPostureTimer = nil
            currentAlertLevel = 0
            return
        }
        
        // 检查免打扰模式：如果开启且检测到全屏应用，则暂停提醒
        if isDoNotDisturbEnabled && isAnyAppFullScreen() {
            if badPostureTimer != nil {
                print("[PostureAlert] 免打扰模式开启且处于全屏，暂停坐姿提醒")
            }
            badPostureStartTime = nil
            badPostureTimer?.invalidate()
            badPostureTimer = nil
            currentAlertLevel = 0
            return
        }
        
        // 如果是良好坐姿，重置提醒
        if posture == .good {
            if badPostureTimer != nil {
                print("[PostureAlert] 恢复良好坐姿，重置提醒")
            }
            badPostureStartTime = nil
            badPostureTimer?.invalidate()
            badPostureTimer = nil
            currentAlertLevel = 0
            return
        }
        
        // 如果是不良坐姿，开始计时
        if badPostureStartTime == nil {
            badPostureStartTime = Date()
            print("[PostureAlert] 开始检测不良坐姿：\(posture.rawValue)")
            startBadPostureTimer()
        }
    }
    
    /// 启动不良坐姿提醒计时器（渐进式提醒）
    private func startBadPostureTimer() {
        badPostureTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self,
                  let startTime = self.badPostureStartTime,
                  self.currentPosture != .good else {
                timer.invalidate()
                return
            }
            
            let elapsed = Int(Date().timeIntervalSince(startTime))
            print("[PostureAlert] 不良坐姿持续时间：\(elapsed)秒，当前坐姿：\(self.currentPosture.rawValue)")
            
            // 渐进式提醒逻辑
            // 3 秒：一级提醒（温和）
            // 10 秒：二级提醒（中等）
            // 20 秒：三级提醒（强烈）
            let newAlertLevel: Int
            if elapsed >= 20 {
                newAlertLevel = 3
            } else if elapsed >= 10 {
                newAlertLevel = 2
            } else if elapsed >= 3 {
                newAlertLevel = 1
            } else {
                return  // 还未到提醒时间
            }
            
            // 只在级别提升时触发提醒
            if newAlertLevel > self.currentAlertLevel {
                print("[PostureAlert] 触发\(newAlertLevel)级提醒")
                self.currentAlertLevel = newAlertLevel
                self.notificationManager.sendPostureAlert(
                    posture: self.currentPosture,
                    level: newAlertLevel,
                    sound: self.isPostureSoundEnabled,
                    haptic: self.isPostureHapticEnabled,
                    banner: self.isPostureBannerEnabled
                )
            }
        }
    }
    
    /// 启动主计时器 (累加专注时间并更新进度)
    private func startMainTimer() {
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.status != .idle else { return }
            self.focusTime += 1
            
            // 处理倒计时目标
            if self.isGoalActive && self.remainingTime > 0 {
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.handleGoalReached()
                }
            }
            
            // 更新进度 (用于 UI 展示)
            if self.isGoalActive {
                self.progress = 1.0 - (self.remainingTime / self.focusGoal)
            } else {
                let hourInSeconds: Double = 3600
                self.progress = (self.focusTime.truncatingRemainder(dividingBy: hourInSeconds)) / hourInSeconds
            }
            
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
                
                // 执行抓拍
                let sampleBuffer = self.faceManager.getCurrentFrame()
                self.takeDistractionSnapshot(sampleBuffer: sampleBuffer, duration: elapsed)
                
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
                
                // 执行抓拍
                let sampleBuffer = self.faceManager.getCurrentFrame()
                self.takeDrowsySnapshot(sampleBuffer: sampleBuffer, duration: elapsed)
                
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
    
    /// 开启/关闭开机自启动
    func toggleLaunchAtLogin() {
        // SMAppService 仅在有正确签名和 Bundle ID 的情况下工作，增加防御
        do {
            if isLaunchAtLoginEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("SMAppService error: \(error.localizedDescription)")
            // 如果失败，回滚状态
            isLaunchAtLoginEnabled = (SMAppService.mainApp.status == .enabled)
        }
        saveDailyStats()
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
        
        self.isDoNotDisturbEnabled = UserDefaults.standard.bool(forKey: "isDoNotDisturbEnabled")
        self.isLaunchAtLoginEnabled = UserDefaults.standard.bool(forKey: "isLaunchAtLoginEnabled")
        self.timerMode = UserDefaults.standard.integer(forKey: "timerMode")
        self.isSnapshotEnabled = UserDefaults.standard.bool(forKey: "isSnapshotEnabled")
        if UserDefaults.standard.object(forKey: "isSnapshotEnabled") == nil { self.isSnapshotEnabled = true }
        
        // 加载坐姿提醒设置
        self.isPostureAlertEnabled = UserDefaults.standard.bool(forKey: "isPostureAlertEnabled")
        if UserDefaults.standard.object(forKey: "isPostureAlertEnabled") == nil { self.isPostureAlertEnabled = true }
        
        self.isPostureSoundEnabled = UserDefaults.standard.bool(forKey: "isPostureSoundEnabled")
        if UserDefaults.standard.object(forKey: "isPostureSoundEnabled") == nil { self.isPostureSoundEnabled = true }
        
        self.isPostureHapticEnabled = UserDefaults.standard.bool(forKey: "isPostureHapticEnabled")
        if UserDefaults.standard.object(forKey: "isPostureHapticEnabled") == nil { self.isPostureHapticEnabled = true }
        
        self.isPostureBannerEnabled = UserDefaults.standard.bool(forKey: "isPostureBannerEnabled")
        if UserDefaults.standard.object(forKey: "isPostureBannerEnabled") == nil { self.isPostureBannerEnabled = true }

        // 加载历史数据
        if let data = UserDefaults.standard.data(forKey: "FocusGuardHistory"),
           let decoded = try? JSONDecoder().decode([DailyStats].self, from: data) {
            self.history = decoded
        }
        
        // 加载抓拍照片数据
        if let data = UserDefaults.standard.data(forKey: "FocusGuardSnapshots"),
           let decoded = try? JSONDecoder().decode([DistractionSnapshot].self, from: data) {
            self.snapshots = decoded
        }
        
        // 获取今日数据
        let todayStr = getTodayString()
        if let today = history.first(where: { $0.date == todayStr }) {
            // 如果找到今天的记录，加载数据
            self.focusTime = today.focusTime
            // 今天的计数从 0 开始，不加载昨天的数据
            self.distractionCount = 0
            self.drowsyCount = 0
        } else {
            // 如果是新的一天，全部重置为 0
            self.focusTime = 0
            self.distractionCount = 0
            self.drowsyCount = 0
        }
    }
    
    private func saveDailyStats() {
        // 保存设置
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled")
        UserDefaults.standard.set(drowsyThreshold, forKey: "drowsyThreshold")
        UserDefaults.standard.set(isDoNotDisturbEnabled, forKey: "isDoNotDisturbEnabled")
        UserDefaults.standard.set(timerMode, forKey: "timerMode")
        UserDefaults.standard.set(isSnapshotEnabled, forKey: "isSnapshotEnabled")
        
        // 保存坐姿提醒设置
        UserDefaults.standard.set(isPostureAlertEnabled, forKey: "isPostureAlertEnabled")
        UserDefaults.standard.set(isPostureSoundEnabled, forKey: "isPostureSoundEnabled")
        UserDefaults.standard.set(isPostureHapticEnabled, forKey: "isPostureHapticEnabled")
        UserDefaults.standard.set(isPostureBannerEnabled, forKey: "isPostureBannerEnabled")

        // 保存统计数据
        let todayStr = getTodayString()
        
        // 检查是否需要归档昨天的数据（跨天情况）
        if let lastRecord = history.first, lastRecord.date != todayStr {
            // 昨天的数据已经在历史记录中，不需要额外操作
            // 因为 lastRecord 的 date 不等于今天，说明是昨天的数据
        }
        
        // 保存或更新今日数据
        if let index = history.firstIndex(where: { $0.date == todayStr }) {
            // 更新今日已存在的记录
            history[index].focusTime = focusTime
            history[index].distractionCount = distractionCount
            history[index].drowsyCount = drowsyCount
        } else {
            // 创建新的一天记录
            let newDay = DailyStats(date: todayStr, focusTime: focusTime, distractionCount: distractionCount, drowsyCount: drowsyCount)
            history.insert(newDay, at: 0)
            // 仅保留最近 30 天
            if history.count > 30 { history.removeLast() }
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "FocusGuardHistory")
        }
    }
    
    /// 保存抓拍照片数据
    private func saveSnapshots() {
        // 仅保留最近 100 张照片
        if snapshots.count > 100 {
            snapshots = Array(snapshots.prefix(100))
        }
        
        if let encoded = try? JSONEncoder().encode(snapshots) {
            UserDefaults.standard.set(encoded, forKey: "FocusGuardSnapshots")
        }
    }
    
    /// 删除指定照片
    func deleteSnapshot(at indexSet: IndexSet) {
        for index in indexSet {
            if index < snapshots.count {
                // 删除文件
                let snapshot = snapshots[index]
                try? FileManager.default.removeItem(atPath: snapshot.imagePath)
            }
        }
        snapshots.remove(atOffsets: indexSet)
        saveSnapshots()
    }
    
    /// 清空所有照片
    func clearAllSnapshots() {
        for snapshot in snapshots {
            try? FileManager.default.removeItem(atPath: snapshot.imagePath)
        }
        snapshots.removeAll()
        saveSnapshots()
    }
    
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// 检查是否有应用处于全屏模式
    private func isAnyAppFullScreen() -> Bool {
        // 通过判断是否有窗口占据了主屏幕的完整显示区域来简单判定
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            // 获取所有可见窗口的描述
            let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
            let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
            
            for window in windowList {
                if let bounds = window[kCGWindowBounds as String] as? [String: Any],
                   let width = bounds["Width"] as? CGFloat,
                   let height = bounds["Height"] as? CGFloat {
                    // 如果某个窗口的宽高几乎等于屏幕宽高，判定为全屏
                    if abs(width - screenFrame.width) < 10 && abs(height - screenFrame.height) < 10 {
                        // 排除 Dock 和系统菜单栏 (通常它们也是全屏宽度的)
                        if let ownerName = window[kCGWindowOwnerName as String] as? String,
                           ownerName != "Window Server" && ownerName != "Dock" {
                            return true
                        }
                    }
                }
            }
        }
        return false
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
