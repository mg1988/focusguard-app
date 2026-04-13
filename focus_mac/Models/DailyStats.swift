import Foundation

/// 每日统计数据模型
struct DailyStats: Identifiable, Codable {
    var id: String { date }
    let date: String // 格式: yyyy-MM-dd
    var focusTime: TimeInterval
    var distractionCount: Int
    var drowsyCount: Int
    
    static var empty: DailyStats {
        DailyStats(date: "", focusTime: 0, distractionCount: 0, drowsyCount: 0)
    }
}
