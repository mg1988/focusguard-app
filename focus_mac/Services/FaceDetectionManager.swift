import Foundation
import AVFoundation
import Vision
import Combine

/// 人脸检测管理服务，负责摄像头采集与面部识别逻辑
class FaceDetectionManager: NSObject, ObservableObject {
    static let shared = FaceDetectionManager()
    
    @Published var isFaceDetected: Bool = false
    @Published var isEyesClosed: Bool = false // 增加眼睛闭合状态
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let faceLandmarksRequest = VNDetectFaceLandmarksRequest() // 改为 LandMarks 以便检测眼睛
    private let sessionQueue = DispatchQueue(label: "com.focusguard.camera.queue")
    
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
                }
                
                DispatchQueue.main.async {
                    self.isFaceDetected = faceFound
                    self.isEyesClosed = eyesClosed
                }
            }
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    /// 根据眼睛特征点判断是否闭眼 (使用 EAR 算法：Eye Aspect Ratio)
    private func checkEyesClosed(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D) -> Bool {
        let leftEAR = calculateEAR(for: leftEye)
        let rightEAR = calculateEAR(for: rightEye)
        
        // 通常 EAR 小于 0.2 被视为闭眼
        let threshold: CGFloat = 0.22
        return leftEAR < threshold && rightEAR < threshold
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
}
