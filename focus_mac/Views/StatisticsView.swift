import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("history_7_days", comment: ""))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let stats = viewModel.last7DaysStats
            
            VStack(spacing: 12) {
                StatRow(title: NSLocalizedString("total_focus", comment: ""), value: formatTime(stats.totalTime), color: .green)
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
