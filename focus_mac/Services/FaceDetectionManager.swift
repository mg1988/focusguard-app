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
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var snapshotTaken: Bool = false // 抓拍完成标记
    @Published var currentPosture: PostureState = .good // 当前坐姿
    @Published var isPostureDetectionEnabled: Bool = true // 是否启用坐姿检测
    
    // EAR 平滑处理：滑动窗口
    private var leftEARHistory: [CGFloat] = []
    private var rightEARHistory: [CGFloat] = []
    private let earWindowSize = 8 // 增加窗口大小到 8 帧，更平滑
    private var consecutiveClosedCount: Int = 0 // 连续闭眼计数
    private let consecutiveThreshold: Int = 3 // 需要连续 3 帧检测到闭眼才判定
    
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
            }
        }
    }
}

extension FaceDetectionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
    
    /// 根据眼睛特征点判断是否闭眼 (使用平滑后的 EAR 算法 + 连续帧验证)
    private func checkEyesClosed(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D) -> Bool {
        let leftEAR = calculateEAR(for: leftEye)
        let rightEAR = calculateEAR(for: rightEye)
        
        // 更新历史记录
        leftEARHistory.append(leftEAR)
        rightEARHistory.append(rightEAR)
        
        if leftEARHistory.count > earWindowSize { leftEARHistory.removeFirst() }
        if rightEARHistory.count > earWindowSize { rightEARHistory.removeFirst() }
        
        // 计算滑动窗口平均值
        let avgLeftEAR = leftEARHistory.reduce(0, +) / CGFloat(leftEARHistory.count)
        let avgRightEAR = rightEARHistory.reduce(0, +) / CGFloat(rightEARHistory.count)
        
        // 提高阈值到 0.25，降低敏感度（原为 0.22）
        let threshold: CGFloat = 0.25
        let isClosed = avgLeftEAR < threshold && avgRightEAR < threshold
        
        // 使用连续帧验证，避免误判
        if isClosed {
            consecutiveClosedCount += 1
            // 只有连续检测到闭眼才判定为闭眼
            return consecutiveClosedCount >= consecutiveThreshold
        } else {
            // 睁眼时重置计数器
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
        let posture = analyzePostureFromLandmarks(faceObservation: faceObservation, faceSize: avgFaceSize)
        
        DispatchQueue.main.async {
            self.currentPosture = posture
        }
    }
    
    /// 从面部地标分析坐姿
    private func analyzePostureFromLandmarks(faceObservation: VNFaceObservation, faceSize: CGFloat) -> PostureState {
        // 距离检测（基于面部大小）
        // 正常面部大小约为 0.15-0.25（归一化坐标）
        if faceSize > 0.35 {
            return .tooClose  // 太近
        } else if faceSize < 0.10 {
            return .tooFar  // 太远
        }
        
        // 使用面部地标检测低头（弯腰驼背）
        if let landmarks = faceObservation.landmarks {
            // 检测鼻子和嘴巴的相对位置
            if let nose = landmarks.nose,
               let mouth = landmarks.outerLips,
               nose.pointCount > 0,
               mouth.pointCount > 0 {
                
                let nosePoint = nose.normalizedPoints[0]
                let mouthPoint = mouth.normalizedPoints[0]
                
                // 计算鼻子到嘴巴的垂直距离
                let verticalDist = nosePoint.y - mouthPoint.y
                
                // 如果垂直距离过大，说明在低头
                if verticalDist > 0.08 {
                    return .slouching
                }
            }
            
            // 检测眼睛水平位置（判断侧倾）
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
                
                // 计算两眼高度差
                let heightDiff = abs(leftCenter.y - rightCenter.y)
                
                // 高度差过大说明侧倾
                if heightDiff > 0.05 {
                    return .leaning
                }
            }
        }
        
        // 良好坐姿
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
