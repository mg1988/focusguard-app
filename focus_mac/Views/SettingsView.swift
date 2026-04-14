import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // --- 提醒设置区块 ---
                    SettingsSection(title: NSLocalizedString("notification_settings", comment: "通知与反馈")) {
                        SettingsRow(icon: "speaker.wave.2.fill", color: .blue, title: NSLocalizedString("sound_alerts", comment: "")) {
                            Toggle("", isOn: $viewModel.isSoundEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        
                        SettingsRow(icon: "hand.tap.fill", color: .indigo, title: NSLocalizedString("haptic_alerts", comment: "")) {
                            Toggle("", isOn: $viewModel.isHapticEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .help(NSLocalizedString("haptic_desc", comment: ""))
                        
                        SettingsRow(icon: "moon.fill", color: .purple, title: NSLocalizedString("do_not_disturb", comment: "")) {
                            Toggle("", isOn: $viewModel.isDoNotDisturbEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle(NSLocalizedString("dnd_desc", comment: ""))
                        
                        SettingsRow(icon: "link", color: .blue, title: NSLocalizedString("system_focus_sync", comment: "")) {
                            Toggle("", isOn: $viewModel.isSystemFocusSyncEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle(NSLocalizedString("system_focus_sync_desc", comment: ""))
                    }
                    
                    // --- 专注功能区块 ---
                    SettingsSection(title: NSLocalizedString("focus_function", comment: "专注功能")) {
                        SettingsRow(icon: "timer", color: .orange, title: NSLocalizedString("timer_mode", comment: "")) {
                            Picker("", selection: $viewModel.timerMode) {
                                Text(NSLocalizedString("timer_up", comment: "")).tag(0)
                                Text(NSLocalizedString("timer_down", comment: "")).tag(1)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                        
                        SettingsRow(icon: "camera.viewfinder", color: .green, title: NSLocalizedString("enable_snapshots", comment: "")) {
                            Toggle("", isOn: $viewModel.isSnapshotEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle(NSLocalizedString("snapshots_description", comment: ""))
                    }
                    
                    // --- 坐姿检测区块 ---
                    SettingsSection(title: NSLocalizedString("posture_detection_settings", comment: "坐姿检测")) {
                        SettingsRow(icon: "figure.stand", color: .cyan, title: NSLocalizedString("enable_posture_detection", comment: "")) {
                            Toggle("", isOn: $viewModel.isPostureDetectionEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        
                        if viewModel.isPostureDetectionEnabled {
                            SettingsRow(icon: "bell.badge.fill", color: .red, title: NSLocalizedString("enable_posture_alert", comment: "")) {
                                Toggle("", isOn: $viewModel.isPostureAlertEnabled).toggleStyle(.switch).labelsHidden()
                            }
                            .subtitle(NSLocalizedString("posture_alert_description", comment: ""))
                            
                            if viewModel.isPostureAlertEnabled {
                                VStack(spacing: 12) {
                                    Toggle(NSLocalizedString("posture_sound_alert", comment: ""), isOn: $viewModel.isPostureSoundEnabled)
                                        .toggleStyle(.checkbox)
                                    Toggle(NSLocalizedString("posture_haptic_alert", comment: ""), isOn: $viewModel.isPostureHapticEnabled)
                                        .toggleStyle(.checkbox)
                                    Toggle(NSLocalizedString("posture_banner_alert", comment: ""), isOn: $viewModel.isPostureBannerEnabled)
                                        .toggleStyle(.checkbox)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 38)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    
                    // --- 阈值与高级设置区块 ---
                    SettingsSection(title: NSLocalizedString("advanced_settings", comment: "高级设置")) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label {
                                    Text(NSLocalizedString("drowsy_threshold", comment: ""))
                                } icon: {
                                    Image(systemName: "eye.fill").foregroundColor(.blue)
                                }
                                Spacer()
                                Text("\(Int(viewModel.drowsyThreshold))s").bold().foregroundColor(.accentColor)
                            }
                            Slider(value: $viewModel.drowsyThreshold, in: 1...5, step: 1)
                        }
                        .padding(.vertical, 4)
                        
                        Divider().padding(.vertical, 4)
                        
                        SettingsRow(icon: "eye.trianglebadge.exclamationmark.fill", color: .orange, title: NSLocalizedString("small_eyes_mode", comment: "")) {
                            Toggle("", isOn: $viewModel.isSmallEyesModeEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle(NSLocalizedString("small_eyes_desc", comment: ""))
                        
                        Divider().padding(.vertical, 4)
                        
                        SettingsRow(icon: "arrow.up.right.square.fill", color: .gray, title: NSLocalizedString("launch_at_login", comment: "")) {
                            Toggle("", isOn: $viewModel.isLaunchAtLoginEnabled).toggleStyle(.switch).labelsHidden()
                                .onChange(of: viewModel.isLaunchAtLoginEnabled) { _ in
                                    viewModel.toggleLaunchAtLogin()
                                }
                        }
                    }
                    
                    // --- 数据操作区块 ---
                    VStack(spacing: 12) {
                        Button(action: { exportData() }) {
                            Label(NSLocalizedString("export_data", comment: ""), systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        Button(action: { openSnapshotFolder() }) {
                            Label(NSLocalizedString("open_snapshot_folder", comment: ""), systemImage: "folder.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            
            // 底部退出
            VStack(spacing: 0) {
                Divider()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack {
                        Image(systemName: "power")
                        Text(NSLocalizedString("quit", comment: "Quit App"))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .background(Color.primary.opacity(0.03))
        }
    }
    
    private func exportData() {
        DispatchQueue.main.async {
            let header = "Date,FocusTime(s),Distractions,Drowsy\n"
            let rows = viewModel.history.map { "\($0.date),\($0.focusTime),\($0.distractionCount),\($0.drowsyCount)" }.joined(separator: "\n")
            let csvContent = header + rows
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.commaSeparatedText]
            savePanel.nameFieldStringValue = "FocusGuard_Stats.csv"
            
            savePanel.begin { result in
                if result == .OK, let url = savePanel.url {
                    do {
                        try csvContent.write(to: url, atomically: true, encoding: .utf8)
                    } catch {
                        print("Failed to save CSV: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func openSnapshotFolder() {
        DispatchQueue.main.async {
            let fileManager = FileManager.default
            guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let snapshotsDir = documentsDir.appendingPathComponent("Snapshots", isDirectory: true)
            
            // 如果文件夹不存在，则创建
            if !fileManager.fileExists(atPath: snapshotsDir.path) {
                do {
                    try fileManager.createDirectory(at: snapshotsDir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create snapshots folder: \(error.localizedDescription)")
                }
            }
            
            // 在 Finder 中打开
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: snapshotsDir.path)
        }
    }
}

// --- 优雅的 UI 组件库 ---

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(NSColor.windowBackgroundColor).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let color: Color
    let title: String
    var subtitle: String? = nil
    let content: Content
    
    init(icon: String, color: Color, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.color = color
        self.title = title
        self.content = content()
    }
    
    func subtitle(_ text: String) -> SettingsRow {
        var copy = self
        copy.subtitle = text
        return copy
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                content
            }
            .padding(.vertical, 6)
        }
    }
}
