import SwiftUI
import AppKit

/// 专注应用的主视图，整合数据展示、灵敏度控制与开关逻辑
struct MainView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航/标题栏
            HStack {
                Text(NSLocalizedString("app_name", comment: ""))
                    .font(.system(size: 18, weight: .heavy))
                Spacer()
                StatusIndicator(
                    status: viewModel.status,
                    isFaceDetected: viewModel.isFaceDetected,
                    isEyesClosed: viewModel.isEyesClosed
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Tab 切换
            Picker("", selection: $selectedTab) {
                Text(NSLocalizedString("tab_focus", comment: "")).tag(0)
                Text(NSLocalizedString("tab_stats", comment: "")).tag(1)
                Text(NSLocalizedString("tab_settings", comment: "")).tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // 内容区域
            ZStack {
                if selectedTab == 0 {
                    FocusContentView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                } else if selectedTab == 1 {
                    StatisticsView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    SettingsView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
        }
        .frame(width: 360, height: 480) // 调整为更紧凑的菜单尺寸
        .background(
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
        )
    }
}

/// 专注核心内容视图
struct FocusContentView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // 数据卡片展示
            VStack(spacing: 12) {
                StatCard(
                    title: NSLocalizedString("focus_time", comment: ""),
                    value: viewModel.formattedFocusTime,
                    iconName: "timer",
                    color: .green
                )
                
                HStack(spacing: 12) {
                    StatCard(
                        title: NSLocalizedString("distractions", comment: ""),
                        value: "\(viewModel.distractionCount)",
                        iconName: "figure.walk",
                        color: .orange
                    )
                    
                    StatCard(
                        title: NSLocalizedString("drowsiness", comment: ""),
                        value: "\(viewModel.drowsyCount)",
                        iconName: "eye.slash",
                        color: .blue
                    )
                }
            }
            
            Spacer()
            
            // 灵敏度
            SensitivityPicker(
                selection: $viewModel.sensitivity,
                isEnabled: viewModel.status == .idle
            )
            
            // 按钮
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.toggleFocusMode()
                }
            }) {
                Text(viewModel.status == .idle ? NSLocalizedString("start_detection", comment: "") : NSLocalizedString("stop_detection", comment: ""))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.status == .idle ? Color.accentColor : Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: (viewModel.status == .idle ? Color.accentColor : Color.red).opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
    }
}

/// 辅助视图：提供 macOS 原生视觉效果 (磨砂玻璃背景)
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
