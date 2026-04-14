import Foundation
import AVFoundation
import Vision
import Combine
import AppKit

/// 人脸检测管理服务，负责摄像头采集与面部识别逻辑
class FaceDetectionManager: NSObject, ObservableObject {
    static let shared = FaceDetectionManager()
    
    @Published var isFaceDetected: Bool = false
    @Published var isEyesClosed: Bool = false // 眼睛状态
    @Published var isSmallEyesModeEnabled: Bool = false // 是否启用小眼睛模式
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var snapshotTaken: Bool = false // 抓拍完成标记
    @Published var currentPosture: PostureState = .good // 当前坐姿
    @Published var isPostureDetectionEnabled: Bool = true // 是否启用坐姿检测
    
    // EAR 动态校准机制
    private var baseEAR: CGFloat = 0.28 // 默认睁眼基准值
    private var earCalibrationHistory: [CGFloat] = []
    private let calibrationSize = 50 // 使用 50 帧来建立基准（约 1.5 秒）
    
    // EAR 平滑处理：滑动窗口
    private var leftEARHistory: [CGFloat] = []
    private var rightEARHistory: [CGFloat] = []
    private let earWindowSize = 12 // 增加到 12 帧（约 0.4 秒），让波动更平缓
    private var consecutiveClosedCount: Int = 0 // 连续闭眼计数
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest() // 改为 LandMarks 以便检测眼睛
    private let sessionQueue = DispatchQueue(label: "com.focusguard.camera.queue")
    
    // 抓拍相关
    private var lastSnapshotTime: Date?
    private let snapshotCooldown: TimeInterval = 5.0 // 抓拍冷却时间，避免连续抓拍
    private var currentSampleBuffer: CMSampleBuffer? // 保存当前帧用于抓拍
    
    // 坐姿检测相关
    private var faceRectHistory: [CGRect] = []
    private let faceRectWindowSize = 10 // 面部位置滑动窗口
    private var postureHistory: [PostureState] = [] // 坐姿状态历史记录
    private let postureWindowSize = 15 // 坐姿状态滑动窗口，约 0.5 秒 (30fps)
    private var badPostureStartTime: Date?
    private let badPostureThreshold: TimeInterval = 3.0 // 不良坐姿持续时间阈值
    
    private override init() {
        super.init()
        checkPermission()
        setupCaptureSession()
    }
    
    /// 检查并请求摄像头权限
    func checkPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraPermissionStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermissionStatus = granted ? .authorized : .denied
                }
            }
        }
    }
    
    /// 配置 AVCaptureSession 与 Vision 请求
    private func setupCaptureSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            
            // 查找合适的视频设备
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            
            if let videoDevice = discoverySession.devices.first,
               let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
               self.captureSession.canAddInput(videoDeviceInput) {
                self.captureSession.addInput(videoDeviceInput)
            }
            
            // 设置输出
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
                self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    /// 启动人脸检测
    func startDetection() {
        // 先检查是否有摄像头
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        guard !discoverySession.devices.isEmpty else {
            print("No camera device found")
            return
        }
        
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    /// 停止人脸检测
    func stopDetection() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            DispatchQueue.main.async {
                self.isFaceDetected = false
                self.isEyesClosed = false
                self.currentPosture = .good
                self.postureHistory.removeAll()
                self.faceRectHistory.removeAll()
                self.leftEARHistory.removeAll()
                self.rightEARHistory.removeAll()
                self.consecutiveClosedCount = 0
            }
        }
    }
}

extension FaceDetectionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 如果 Session 已经不在运行，直接返回，不处理任何数据
        guard captureSession.isRunning else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // 保存当前帧用于抓拍
        self.currentSampleBuffer = sampleBuffer
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
            if let results = faceLandmarksRequest.results {
                let faceFound = !results.isEmpty
                var eyesClosed = false
                
                if let face = results.first {
                    // 通过眼睛轮廓点判断是否闭眼 (简单启发式逻辑)
                    if let leftEye = face.landmarks?.leftEye,
                       let rightEye = face.landmarks?.rightEye {
                        eyesClosed = checkEyesClosed(leftEye: leftEye, rightEye: rightEye)
                    }
                    
                    // 检测坐姿
                    detectPosture(faceObservation: face)
                } else {
                    // 如果没检测到脸，将坐姿设为 good 或保持现状，避免误报
                    // 此处选择清空坐姿历史，这样恢复时需要重新判定
                    DispatchQueue.main.async {
                        self.postureHistory.removeAll()
                        self.currentPosture = .good
                    }
                }
                
                DispatchQueue.main.async {
                    self.isFaceDetected = faceFound
                    self.isEyesClosed = eyesClosed
                    self.snapshotTaken = false // 重置抓拍标记
                }
            }
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    /// 获取当前帧用于抓拍
    func getCurrentFrame() -> CMSampleBuffer? {
        return currentSampleBuffer
    }
    
    /// 根据眼睛特征点判断是否闭眼 (动态校准算法)
    private func checkEyesClosed(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D) -> Bool {
        let leftEAR = calculateEAR(for: leftEye)
        let rightEAR = calculateEAR(for: rightEye)
        let currentEAR = (leftEAR + rightEAR) / 2.0
        
        // 1. 动态校准：如果 EAR 比较高，说明用户睁着眼，更新基准值
        if currentEAR > 0.22 {
            earCalibrationHistory.append(currentEAR)
            if earCalibrationHistory.count > calibrationSize {
                earCalibrationHistory.removeFirst()
                // 基准值设为历史最高 20% 的平均值，代表用户“睁眼”时的常态
                let sorted = earCalibrationHistory.sorted()
                let topIndex = Int(Double(calibrationSize) * 0.8)
                baseEAR = sorted[topIndex...].reduce(0, +) / CGFloat(calibrationSize - topIndex)
            }
        }
        
        // 2. 更新平滑历史
        leftEARHistory.append(leftEAR)
        rightEARHistory.append(rightEAR)
        if leftEARHistory.count > earWindowSize { leftEARHistory.removeFirst() }
        if rightEARHistory.count > earWindowSize { rightEARHistory.removeFirst() }
        
        let avgLeftEAR = leftEARHistory.reduce(0, +) / CGFloat(leftEARHistory.count)
        let avgRightEAR = rightEARHistory.reduce(0, +) / CGFloat(rightEARHistory.count)
        let avgEAR = (avgLeftEAR + avgRightEAR) / 2.0
        
        // 3. 核心判定逻辑：相对于“个人睁眼基准”下掉 35% 以上才判定为闭眼
        // 这种相对比例法对小眼睛非常有效，因为它是根据你自己的眼睛大小来算的
        // 如果开启“小眼睛模式”，则下掉 50% 以上才判定为闭眼，且增加确认时长
        let dropThreshold = isSmallEyesModeEnabled ? 0.50 : 0.65
        let dynamicThreshold = baseEAR * dropThreshold 
        let isClosed = avgEAR < dynamicThreshold
        
        // 增加确认时间：正常模式 12 帧，小眼睛模式 25 帧 (约 0.8 秒)
        let confirmationFrames = isSmallEyesModeEnabled ? 25 : 12
        if isClosed {
            consecutiveClosedCount += 1
            return consecutiveClosedCount >= confirmationFrames
        } else {
            consecutiveClosedCount = 0
            return false
        }
    }
    
    /// 计算单只眼睛的纵横比 (EAR)
    private func calculateEAR(for eye: VNFaceLandmarkRegion2D) -> CGFloat {
        guard eye.pointCount >= 6 else { return 1.0 }
        
        let points = eye.normalizedPoints
        
        // EAR = (|p2-p6| + |p3-p5|) / (2 * |p1-p4|)
        // VNFaceLandmarkRegion2D 的点位分布：
        // 0: 内眼角, 3: 外眼角, 1,2: 上眼睑, 4,5: 下眼睑 (具体取决于 Vision 版本，此处为通用估算)
        
        let p1 = points[0]
        let p2 = points[1]
        let p3 = points[2]
        let p4 = points[3]
        let p5 = points[4]
        let p6 = points[5]
        
        let v1 = dist(p2, p6)
        let v2 = dist(p3, p5)
        let h = dist(p1, p4)
        
        guard h > 0 else { return 1.0 }
        return (v1 + v2) / (2.0 * h)
    }
    
    private func dist(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
    
    /// 检测坐姿
    /// - Parameter faceObservation: 面部观察对象
    func detectPosture(faceObservation: VNFaceObservation) {
        guard isPostureDetectionEnabled else {
            currentPosture = .good
            return
        }
        
        // 1. 检测面部位置（判断距离）
        let faceRect = faceObservation.boundingBox
        faceRectHistory.append(faceRect)
        
        if faceRectHistory.count > faceRectWindowSize {
            faceRectHistory.removeFirst()
        }
        
        // 计算平均面部大小
        let avgFaceSize = faceRectHistory.reduce(0) { $0 + $1.size.width } / CGFloat(faceRectHistory.count)
        
        // 2. 使用面部地标检测头部姿态
        let rawPosture = analyzePostureFromLandmarks(faceObservation: faceObservation, faceSize: avgFaceSize)
        
        // 3. 平滑处理：使用滑动窗口投票机制
        postureHistory.append(rawPosture)
        if postureHistory.count > postureWindowSize {
            postureHistory.removeFirst()
        }
        
        // 统计窗口中出现最多的状态
        let smoothedPosture = getMostFrequentPosture(in: postureHistory)
        
        DispatchQueue.main.async {
            if self.currentPosture != smoothedPosture {
                self.currentPosture = smoothedPosture
            }
        }
    }
    
    /// 获取窗口中出现最频繁的坐姿
    private func getMostFrequentPosture(in history: [PostureState]) -> PostureState {
        guard !history.isEmpty else { return .good }
        
        var counts: [PostureState: Int] = [:]
        for state in history {
            counts[state, default: 0] += 1
        }
        
        // 优先返回非良好的姿态，以便更敏感地触发提醒，但需要足够多的帧数确认
        // 如果 good 的比例很高（比如 > 80%），才判定为 good
        let goodCount = counts[.good, default: 0]
        if Double(goodCount) / Double(history.count) > 0.8 {
            return .good
        }
        
        // 否则返回最频繁的非良好姿态
        return counts.filter { $0.key != .good }
            .max { $0.value < $1.value }?
            .key ?? .good
    }
    
    /// 从面部地标分析坐姿
    private func analyzePostureFromLandmarks(faceObservation: VNFaceObservation, faceSize: CGFloat) -> PostureState {
        // 距离检测：适当扩大正常范围 (0.08 - 0.38)
        if faceSize > 0.38 {
            return .tooClose
        } else if faceSize < 0.08 {
            return .tooFar
        }
        
        // 使用面部地标检测
        if let landmarks = faceObservation.landmarks {
            // 低头检测：增加垂直距离的阈值，允许轻微低头
            if let nose = landmarks.nose,
               let mouth = landmarks.outerLips,
               nose.pointCount > 0,
               mouth.pointCount > 0 {
                
                let nosePoint = nose.normalizedPoints[0]
                let mouthPoint = mouth.normalizedPoints[0]
                let verticalDist = nosePoint.y - mouthPoint.y
                
                // 阈值从 0.08 提高到 0.12，显著降低“弯腰”误判
                if verticalDist > 0.12 {
                    return .slouching
                }
            }
            
            // 侧倾检测：增加高度差阈值，允许头部自然倾斜
            if let leftEye = landmarks.leftEye,
               let rightEye = landmarks.rightEye,
               leftEye.pointCount > 0,
               rightEye.pointCount > 0 {
                
                let leftCenter = leftEye.normalizedPoints.reduce(CGPoint(x: 0, y: 0)) {
                    CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)
                }
                let rightCenter = rightEye.normalizedPoints.reduce(CGPoint(x: 0, y: 0)) {
                    CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)
                }
                
                let heightDiff = abs(leftCenter.y - rightCenter.y)
                
                // 阈值从 0.05 提高到 0.08，减少侧倾误判
                if heightDiff > 0.08 {
                    return .leaning
                }
            }
        }
        
        return .good
    }
    
    /// 抓拍当前帧并保存为图片
    /// - Parameters:
    ///   - sampleBuffer: 当前的视频帧
    ///   - type: 抓拍类型（走神或瞌睡）
    ///   - duration: 触发抓拍的持续时间
    /// - Returns: 抓拍照片的文件路径
    func captureSnapshot(from sampleBuffer: CMSampleBuffer, type: SnapshotType, duration: TimeInterval) -> String? {
        // 检查冷却时间
        if let lastTime = lastSnapshotTime,
           Date().timeIntervalSince(lastTime) < snapshotCooldown {
            return nil
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        // 将 PixelBuffer 转换为 CGImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        // 生成文件名和保存路径
        let fileName = "\(type.rawValue)_\(Date().timeIntervalSince1970).jpg"
        let fileManager = FileManager.default
        
        // 获取 Documents 目录
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let snapshotsDir = documentsDir.appendingPathComponent("Snapshots", isDirectory: true)
        
        // 创建快照目录（如果不存在）
        if !fileManager.fileExists(atPath: snapshotsDir.path) {
            try? fileManager.createDirectory(at: snapshotsDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        let filePath = snapshotsDir.appendingPathComponent(fileName)
        
        // 保存为 JPEG 图片
        if let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [.compressionFactor: 0.8]),
           fileManager.createFile(atPath: filePath.path, contents: data, attributes: nil) {
            lastSnapshotTime = Date()
            return filePath.path
        }
        
        return nil
    }
}
