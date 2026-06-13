import SwiftUI
import AppKit

/// 专注应用的主视图，整合数据展示、灵敏度控制与开关逻辑
struct MainView: View {
    @ObservedObject var viewModel: FocusViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showPrivacyMask = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航/标题栏
            VStack(spacing: 12) {
                HStack {
                    Text("app_name".localized)
                        .font(.system(size: 18, weight: .heavy))
                    Spacer()
                    StatusIndicator(
                        status: viewModel.status,
                        isFaceDetected: viewModel.isFaceDetected,
                        isEyesClosed: viewModel.isEyesClosed
                    )
                    .onTapGesture {
                        // 快速点击指示器显示隐私说明
                        showPrivacyMask = true
                    }
                }
                
                // 坐姿状态指示器
                if viewModel.isPostureDetectionEnabled {
                    PostureIndicatorView(posture: viewModel.currentPosture)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .sheet(isPresented: $showPrivacyMask) {
                PrivacyMaskView()
            }
            
            // Tab 切换
            Picker("", selection: $selectedTab) {
                Text("tab_focus".localized).tag(0)
                Text("tab_stats".localized).tag(1)
                Text("tab_settings".localized).tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // 内容区域
            ZStack {
                if selectedTab == 0 {
                    FocusContentView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .scale(scale: 1.05).combined(with: .opacity)))
                } else if selectedTab == 1 {
                    StatisticsView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    SettingsView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .scale(scale: 1.05).combined(with: .opacity)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
            .onChange(of: selectedTab) { _ in
                // 切换 Tab 时触发微小的触感反馈
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            }
        }
        .frame(width: 360, height: 480) // 调整为更紧凑的菜单尺寸
        .background(
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
        )
        .id(languageManager.languageRefreshID) // 监听语言变化，强制刷新整个 UI
    }
}

/// Touch Bar 视图定义
struct PostureTouchBarView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.currentPosture.iconName)
                .imageScale(.large)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(viewModel.currentPosture == .good ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentPosture.localizedName)
                    .font(.system(size: 13, weight: .bold))
                
                if viewModel.status == .active {
                    Text(viewModel.formattedFocusTime)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

/// 专注核心内容视图
struct FocusContentView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 数据卡片展示
                VStack(spacing: 8) {
                    StatCard(
                        title: "focus_time".localized,
                        value: viewModel.isGoalActive ? formatTime(viewModel.remainingTime) : viewModel.formattedFocusTime,
                        iconName: viewModel.isGoalActive ? "hourglass" : "timer",
                        color: .green
                    )
                    
                    HStack(spacing: 8) {
                        StatCard(
                            title: "distractions".localized,
                            value: "\(viewModel.distractionCount)",
                            iconName: "figure.walk",
                            color: .orange
                        )
                        
                        StatCard(
                        title: "drowsiness".localized,
                        value: "\(viewModel.drowsyCount)",
                        iconName: "eye.slash",
                        color: .blue
                    )
                }
            }
                .padding(.top, 4)
                
                // 专注目标设置 (仅在待命状态可见)
                if viewModel.status == .idle {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("focus_goal".localized)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        // 预设目标时长网格
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach([15, 25, 45, 60, 90, 120], id: \.self) { mins in
                                GoalButton(
                                    label: "\(mins)m",
                                    isSelected: viewModel.focusGoal == TimeInterval(mins * 60) && viewModel.isGoalActive,
                                    action: {
                                        viewModel.focusGoal = TimeInterval(mins * 60)
                                        viewModel.remainingTime = viewModel.focusGoal
                                        viewModel.isGoalActive = true
                                    }
                                )
                            }
                            
                            GoalButton(
                                icon: "infinity",
                                isSelected: !viewModel.isGoalActive,
                                action: { viewModel.isGoalActive = false }
                            )
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.primary.opacity(0.04)))
                }
                
                // 灵敏度设置
                SensitivityPicker(
                    selection: $viewModel.sensitivity,
                    isEnabled: viewModel.status == .idle
                )
                .padding(.vertical, 8)
                
                Spacer(minLength: 20)
                
                // 核心按钮
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleFocusMode()
                    }
                }) {
                    Text(viewModel.status == .idle ? "start_detection".localized : "stop_detection".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.status == .idle ? Color.accentColor : Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: (viewModel.status == .idle ? Color.accentColor : Color.red).opacity(0.2), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

/// 自定义目标选择按钮
struct GoalButton: View {
    var label: String? = nil
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if let label = label {
                    Text(label)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .font(.system(size: 12, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.primary.opacity(0.05))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
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
        MainView(viewModel: FocusViewModel())
    }
}
