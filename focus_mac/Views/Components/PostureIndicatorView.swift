import SwiftUI

/// 坐姿检测状态指示器
struct PostureIndicatorView: View {
    let posture: PostureState
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: posture.iconName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(postureColor)
            
            Text(posture.localizedName)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(postureColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var postureColor: Color {
        switch posture {
        case .good:
            return .green
        case .slouching, .leaning, .tooClose, .tooFar:
            return .orange
        }
    }
}

struct PostureIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PostureIndicatorView(posture: .good)
            PostureIndicatorView(posture: .slouching)
            PostureIndicatorView(posture: .leaning)
            PostureIndicatorView(posture: .tooClose)
            PostureIndicatorView(posture: .tooFar)
        }
        .padding()
    }
}
