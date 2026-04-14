import SwiftUI

/// 动态菜单栏图标视图，实时展示专注进度
struct DynamicMenuBarIcon: View {
    let progress: Double
    let status: FocusStatus
    let remainingTime: TimeInterval
    let focusTime: TimeInterval
    let isGoalActive: Bool
    let timerMode: Int
    let currentPosture: PostureState  // 当前坐姿
    let isPostureAlertActive: Bool    // 是否正在坐姿提醒
    
    @State private var isBlinking: Bool = false  // 闪烁状态
    
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
                Image(systemName: isGoalActive ? "hourglass" : iconSymbol)
                    .font(.system(size: 8, weight: .bold)) // 稍微调大一点中心图标
                    .foregroundColor(displayColor)
            }
            .frame(width: 18, height: 18)
            .scaleEffect(isPostureAlertActive ? 1.1 : 1.0) // 坐姿不良时图标略微放大
            .opacity(isBlinking && isPostureAlertActive ? 0.4 : 1.0)  // 闪烁效果
            .animation(isPostureAlertActive ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isPostureAlertActive)
            
            // 如果坐姿不良且正在提醒，显示状态文字，帮助用户直接在菜单栏看到问题
            if isPostureAlertActive && currentPosture != .good {
                Text(currentPosture.localizedName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
            } else if status != .idle {
                Text(timerMode == 1 && isGoalActive ? formatTime(remainingTime) : formatTime(focusTime))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(displayColor)
            }
        }
        .onAppear {
            if isPostureAlertActive { isBlinking = true }
        }
        .onChange(of: isPostureAlertActive) { newValue in
            withAnimation(newValue ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default) {
                isBlinking = newValue
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
    
    /// 根据坐姿状态返回图标符号
    private var iconSymbol: String {
        if isPostureAlertActive && currentPosture != .good {
            // 坐姿不良时显示警告图标
            switch currentPosture {
            case .slouching: return "figure.bend"
            case .leaning: return "arrow.left.and.right"
            case .tooClose: return "arrow.up.left.and.arrow.down.right"
            case .tooFar: return "arrow.up.right.and.arrow.down.left"
            case .good: return "timer"
            }
        }
        return "timer"
    }
    
    /// 显示颜色（坐姿不良时变为橙色或红色）
    private var displayColor: Color {
        if isPostureAlertActive && currentPosture != .good {
            return .orange  // 坐姿不良时显示橙色
        }
        return statusColor
    }
}
