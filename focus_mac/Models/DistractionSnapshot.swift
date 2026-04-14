import Foundation

/// 走神抓拍数据模型，用于存储抓拍瞬间的照片信息
struct DistractionSnapshot: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let type: SnapshotType
    let imagePath: String
    let duration: TimeInterval
    
    init(id: UUID = UUID(), timestamp: Date = Date(), type: SnapshotType, imagePath: String, duration: TimeInterval) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.imagePath = imagePath
        self.duration = duration
    }
}

/// 抓拍类型枚举
enum SnapshotType: String, Codable {
    case distraction  // 走神（面部离开）
    case drowsy       // 瞌睡（闭眼）
    
    var localizedName: String {
        switch self {
        case .distraction:
            return NSLocalizedString("snapshot_distraction", comment: "走神")
        case .drowsy:
            return NSLocalizedString("snapshot_drowsy", comment: "瞌睡")
        }
    }
    
    var iconName: String {
        switch self {
        case .distraction:
            return "figure.walk"
        case .drowsy:
            return "eye.slash"
        }
    }
}
