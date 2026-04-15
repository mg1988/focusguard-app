import Foundation

/// 坐姿状态枚举
enum PostureState: String, Codable {
    case good         // 良好坐姿
    case slouching    // 弯腰驼背
    case leaning      // 侧倾
    case tooClose     // 距离太近
    case tooFar       // 距离太远
    
    /// 本地化名称
    var localizedName: String {
        switch self {
        case .good:
            return "posture_good".localized
        case .slouching:
            return "posture_slouching".localized
        case .leaning:
            return "posture_leaning".localized
        case .tooClose:
            return "posture_too_close".localized
        case .tooFar:
            return "posture_too_far".localized
        }
    }
    
    /// 图标名称
    var iconName: String {
        switch self {
        case .good:
            return "checkmark.circle.fill"
        case .slouching:
            return "figure.bend"
        case .leaning:
            return "arrow.left.and.right"
        case .tooClose:
            return "arrow.up.left.and.arrow.down.right"
        case .tooFar:
            return "arrow.up.right.and.arrow.down.left"
        }
    }
    
    /// 状态颜色
    var color: String {
        switch self {
        case .good:
            return "green"
        case .slouching, .leaning, .tooClose, .tooFar:
            return "orange"
        }
    }
}

/// 坐姿检测统计数据
struct PostureStats: Codable {
    var goodPostureCount: Int = 0      // 良好坐姿次数
    var badPostureCount: Int = 0       // 不良坐姿次数
    var slouchingCount: Int = 0        // 弯腰次数
    var leaningCount: Int = 0          // 侧倾次数
    var distanceWarningCount: Int = 0  // 距离警告次数
    
    /// 坐姿良好率
    var goodPostureRate: Double {
        let total = goodPostureCount + badPostureCount
        guard total > 0 else { return 0 }
        return Double(goodPostureCount) / Double(total) * 100
    }
}
