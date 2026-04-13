import SwiftUI

/// 动态菜单栏图标视图，实时展示专注进度
struct DynamicMenuBarIcon: View {
    let progress: Double
    let status: FocusStatus
    let remainingTime: TimeInterval
    let isGoalActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                // 背景环
                Circle()
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                
                // 进度环
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.01, progress)))
                    .stroke(
                        statusColor,
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(-90))
                
                // 中心图标
                Image(systemName: isGoalActive ? "hourglass" : "timer")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(statusColor)
            }
            .frame(width: 18, height: 18)
            
            if isGoalActive && status != .idle {
                Text(formatTime(remainingTime))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(statusColor)
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private var statusColor: Color {
        switch status {
        case .idle: return .primary.opacity(0.6)
        case .active: return .green
        case .distracted: return .orange
        }
    }
}
