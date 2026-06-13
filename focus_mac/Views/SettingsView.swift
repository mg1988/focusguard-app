import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // --- 外观设置区块 ---
                    SettingsSection(title: "appearance_settings".localized) {
                        SettingsRow(icon: "paintbrush.fill", color: .purple, title: "theme_mode".localized) {
                            Picker("", selection: $themeManager.currentTheme) {
                                ForEach(AppTheme.allCases) { theme in
                                    Label(theme.localizedName, systemImage: theme.iconName)
                                        .tag(theme)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: themeManager.currentTheme) { newValue in
                                themeManager.setTheme(newValue)
                            }
                        }
                    }
                    
                    // --- 提醒设置区块 ---
                    SettingsSection(title: "notification_settings".localized) {
                        SettingsRow(icon: "speaker.wave.2.fill", color: .blue, title: "sound_alerts".localized) {
                            Toggle("", isOn: $viewModel.isSoundEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        
                        SettingsRow(icon: "hand.tap.fill", color: .indigo, title: "haptic_alerts".localized) {
                            Toggle("", isOn: $viewModel.isHapticEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .help("haptic_desc".localized)
                        
                        SettingsRow(icon: "moon.fill", color: .purple, title: "do_not_disturb".localized) {
                            Toggle("", isOn: $viewModel.isDoNotDisturbEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle("dnd_desc".localized)
                        
                        SettingsRow(icon: "link", color: .blue, title: "system_focus_sync".localized) {
                            Toggle("", isOn: $viewModel.isSystemFocusSyncEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle("system_focus_sync_desc".localized)
                    }
                    
                    // --- 专注功能区块 ---
                    SettingsSection(title: "focus_function".localized) {
                        SettingsRow(icon: "timer", color: .orange, title: "timer_mode".localized) {
                            Picker("", selection: $viewModel.timerMode) {
                                Text("timer_up".localized).tag(0)
                                Text("timer_down".localized).tag(1)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                        
                        SettingsRow(icon: "camera.viewfinder", color: .green, title: "enable_snapshots".localized) {
                            Toggle("", isOn: $viewModel.isSnapshotEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle("snapshots_description".localized)
                    }
                    
                    // --- 坐姿检测区块 ---
                    SettingsSection(title: "posture_detection_settings".localized) {
                        SettingsRow(icon: "figure.stand", color: .cyan, title: "enable_posture_detection".localized) {
                            Toggle("", isOn: $viewModel.isPostureDetectionEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        
                        if viewModel.isPostureDetectionEnabled {
                            SettingsRow(icon: "bell.badge.fill", color: .red, title: "enable_posture_alert".localized) {
                                Toggle("", isOn: $viewModel.isPostureAlertEnabled).toggleStyle(.switch).labelsHidden()
                            }
                            .subtitle("posture_alert_description".localized)
                            
                            if viewModel.isPostureAlertEnabled {
                                VStack(spacing: 12) {
                                    Toggle("posture_sound_alert".localized, isOn: $viewModel.isPostureSoundEnabled)
                                        .toggleStyle(.checkbox)
                                    Toggle("posture_haptic_alert".localized, isOn: $viewModel.isPostureHapticEnabled)
                                        .toggleStyle(.checkbox)
                                    Toggle("posture_banner_alert".localized, isOn: $viewModel.isPostureBannerEnabled)
                                        .toggleStyle(.checkbox)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 38)
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    
                    // --- 阈值与高级设置区块 ---
                    SettingsSection(title: "advanced_settings".localized) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label {
                                    Text("drowsy_threshold".localized)
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
                        
                        SettingsRow(icon: "eye.trianglebadge.exclamationmark.fill", color: .orange, title: "small_eyes_mode".localized) {
                            Toggle("", isOn: $viewModel.isSmallEyesModeEnabled).toggleStyle(.switch).labelsHidden()
                        }
                        .subtitle("small_eyes_desc".localized)
                        
                        Divider().padding(.vertical, 4)
                        
                        SettingsRow(icon: "arrow.up.right.square.fill", color: .gray, title: "launch_at_login".localized) {
                            Toggle("", isOn: $viewModel.isLaunchAtLoginEnabled).toggleStyle(.switch).labelsHidden()
                                .onChange(of: viewModel.isLaunchAtLoginEnabled) { _ in
                                    viewModel.toggleLaunchAtLogin()
                                }
                        }
                    }
                    
                    // --- 语言设置区块 ---
                    SettingsSection(title: "language_settings".localized) {
                        SettingsRow(icon: "globe", color: .purple, title: "language_settings".localized) {
                            Picker("", selection: $viewModel.selectedLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.localizedName).tag(language)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 150)
                            .onChange(of: viewModel.selectedLanguage) { newLanguage in
                                viewModel.changeLanguage(newLanguage)
                            }
                        }
                        .subtitle("language_select_desc".localized)
                    }
                    
                    // --- 数据操作区块 ---
                    VStack(spacing: 12) {
                        Button(action: { exportData() }) {
                            Label("export_data".localized, systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        Button(action: { openSnapshotFolder() }) {
                            Label("open_snapshot_folder".localized, systemImage: "folder.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .id(languageManager.languageRefreshID)  // 使用全局刷新 ID
            
            // 底部退出
            VStack(spacing: 0) {
                Divider()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack {
                        Image(systemName: "power")
                        Text("quit".localized)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
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
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.gradient)
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .regular))
                    
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
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}
