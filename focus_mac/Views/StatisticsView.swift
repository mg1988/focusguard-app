import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("history_7_days", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 新增：专注热力图 (Heatmap)
            FocusHeatmap(history: viewModel.history)
                .frame(height: 100)
                .padding(.vertical, 8)
            
            let stats = viewModel.last7DaysStats
            
            VStack(spacing: 12) {
                StatRow(title: NSLocalizedString("total_focus", comment: ""), value: formatTime(stats.totalTime), color: .green)
                StatRow(title: NSLocalizedString("efficiency", comment: ""), value: "\(viewModel.efficiencyScore)%", color: .yellow)
                StatRow(title: NSLocalizedString("avg_distractions", comment: ""), value: String(format: "%.1f", stats.avgDistraction), color: .orange)
                StatRow(title: NSLocalizedString("avg_drowsy", comment: ""), value: String(format: "%.1f", stats.avgDrowsy), color: .blue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
            
            // 简单的历史列表
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.history.prefix(7)) { day in
                        HStack {
                            Text(day.date).font(.system(.body, design: .monospaced))
                            Spacer()
                            Text(formatTime(day.focusTime)).foregroundColor(.secondary)
                            Image(systemName: "figure.walk").foregroundColor(.orange)
                            Text("\(day.distractionCount)")
                            Image(systemName: "eye.slash").foregroundColor(.blue)
                            Text("\(day.drowsyCount)")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.03)))
                    }
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}

/// GitHub 风格的专注热力图组件
struct FocusHeatmap: View {
    let history: [DailyStats]
    
    // 生成过去 28 天的数据网格 (4周 x 7天)
    private var gridData: [[DailyStats?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var grid: [[DailyStats?]] = Array(repeating: Array(repeating: nil, count: 7), count: 4)
        
        for dayOffset in 0..<28 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dateStr = formatDate(date)
                let weekIndex = 3 - (dayOffset / 7)
                let dayIndex = calendar.component(.weekday, from: date) - 1 // 0-6 (Sun-Sat)
                
                if weekIndex >= 0 {
                    grid[weekIndex][dayIndex] = history.first(where: { $0.date == dateStr })
                }
            }
        }
        return grid
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { weekIndex in
                VStack(spacing: 4) {
                    ForEach(0..<7) { dayIndex in
                        let dayData = gridData[weekIndex][dayIndex]
                        let intensity = calculateIntensity(dayData?.focusTime ?? 0)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(intensityColor(intensity))
                            .frame(width: 10, height: 10)
                            .help(dayData?.date ?? "") // 悬浮提示日期
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func calculateIntensity(_ focusTime: TimeInterval) -> Double {
        // 假设每日专注 4 小时 (14400s) 为满分强度
        let maxTime: TimeInterval = 14400
        return min(focusTime / maxTime, 1.0)
    }
    
    private func intensityColor(_ intensity: Double) -> Color {
        if intensity == 0 { return Color.primary.opacity(0.05) }
        return Color.green.opacity(0.2 + intensity * 0.8)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
    }
}
