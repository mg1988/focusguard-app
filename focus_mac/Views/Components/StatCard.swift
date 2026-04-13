import SwiftUI

/// 统计数据展示卡片组件，支持磨砂玻璃效果与国际化
struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.03))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
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
