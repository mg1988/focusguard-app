import SwiftUI
import AppKit

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
        HStack(spacing: 6) {
            ZStack {
                // 进度环
                Circle()
                    .stroke(Color.primary.opacity(0.15), lineWidth: 2)
                    .frame(width: 18, height: 18)
                
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.01, progress)))
                    .stroke(
                        statusColor,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(-90))
                
                // 中心图标：优先显示坐姿警告，否则显示 AppIcon
                if isPostureAlertActive && currentPosture != .good {
                    Image(systemName: iconSymbol)
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.orange)
                } else if let appIcon = NSApp.applicationIconImage {
                    // 使用应用自身的图标
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                } else {
                    // 备选图标
                    Image(systemName: "timer")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(displayColor)
                }
            }
            .frame(width: 20, height: 20)
            .scaleEffect(isPostureAlertActive ? 1.1 : 1.0)
            .opacity(isBlinking && isPostureAlertActive ? 0.5 : 1.0)
            .animation(isPostureAlertActive ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isPostureAlertActive)
            
            if isPostureAlertActive && currentPosture != .good {
                Text(currentPosture.localizedName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
            } else if status != .idle {
                Text(timerMode == 1 && isGoalActive ? formatTime(remainingTime) : formatTime(focusTime))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(displayColor)
            }
        }
        .padding(.horizontal, 2)
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
