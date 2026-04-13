import SwiftUI

/// 统计数据展示卡片组件，支持磨砂玻璃效果与国际化
struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText()) // 支持数字切换动画
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            StatCard(title: "专注时长", value: "01:23:45", iconName: "timer", color: .green)
            StatCard(title: "走神次数", value: "12", iconName: "exclamationmark.triangle", color: .orange)
        }
        .padding()
        .frame(width: 400)
    }
}
