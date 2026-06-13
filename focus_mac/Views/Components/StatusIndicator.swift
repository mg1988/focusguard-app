import SwiftUI

/// 状态指示器组件，直观展示当前检测状态（待命/检测中/走神中/瞌睡中）
struct StatusIndicator: View {
    let status: FocusStatus
    let isFaceDetected: Bool
    let isEyesClosed: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)
                .shadow(color: indicatorColor.opacity(0.5), radius: 2)
            
            Text(statusText)
                .font(.footnote.monospaced())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.primary.opacity(0.05)))
    }
    
    private var indicatorColor: Color {
        switch status {
        case .idle: return .gray
        case .active: 
            if !isFaceDetected { return .orange }
            if isEyesClosed { return .blue }
            return .green
        case .paused:return .orange
        case .distracted: return .orange
        }
    }
    
    private var statusText: String {
        switch status {
        case .idle: return "status_idle".localized
        case .active: 
            if !isFaceDetected { return "status_distracted".localized }
            if isEyesClosed { return "status_drowsy".localized }
            return "status_detecting".localized
        case .paused: return "status_distracted".localized
        case .distracted: return "status_distracted".localized
        }
    }
}

struct StatusIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatusIndicator(status: .idle, isFaceDetected: false, isEyesClosed: false)
            StatusIndicator(status: .active, isFaceDetected: true, isEyesClosed: false)
            StatusIndicator(status: .active, isFaceDetected: true, isEyesClosed: true)
            StatusIndicator(status: .active, isFaceDetected: false, isEyesClosed: false)
        }
        .padding()
    }
}
