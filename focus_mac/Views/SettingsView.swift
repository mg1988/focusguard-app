import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Text(NSLocalizedString("tab_settings", comment: ""))
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 16) {
                        // 提醒设置
                        Toggle(NSLocalizedString("sound_alerts", comment: ""), isOn: $viewModel.isSoundEnabled)
                            .toggleStyle(.switch)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(NSLocalizedString("haptic_alerts", comment: ""), isOn: $viewModel.isHapticEnabled)
                                .toggleStyle(.switch)
                            
                            Text(NSLocalizedString("haptic_desc", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // 系统设置
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(NSLocalizedString("do_not_disturb", comment: ""), isOn: $viewModel.isDoNotDisturbEnabled)
                                .toggleStyle(.switch)
                            Text(NSLocalizedString("dnd_desc", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Toggle(NSLocalizedString("launch_at_login", comment: ""), isOn: $viewModel.isLaunchAtLoginEnabled)
                            .toggleStyle(.switch)
                            .onChange(of: viewModel.isLaunchAtLoginEnabled) { _ in
                                viewModel.toggleLaunchAtLogin()
                            }
                        
                        Divider()
                        
                        // 计时模式设置
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("timer_mode", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $viewModel.timerMode) {
                                Text(NSLocalizedString("timer_up", comment: "")).tag(0)
                                Text(NSLocalizedString("timer_down", comment: "")).tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Divider()
                        
                        // 抓拍功能设置
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .foregroundColor(.accentColor)
                                Text(NSLocalizedString("snapshot_settings", comment: "抓拍设置"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            Toggle(NSLocalizedString("enable_snapshots", comment: "启用抓拍"), isOn: $viewModel.isSnapshotEnabled)
                                .toggleStyle(.switch)
                            
                            Text(NSLocalizedString("snapshots_description", comment: "走神或瞌睡时自动拍照，帮助回顾专注状态"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "folder")
                                    .foregroundColor(.secondary)
                                Text(NSLocalizedString("snapshot_location", comment: "存储位置"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Documents/Snapshots")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.medium)
                            }
                            
                            Button(action: {
                                openSnapshotFolder()
                            }) {
                                HStack {
                                    Image(systemName: "folder.badge.plus")
                                    Text(NSLocalizedString("open_snapshot_folder", comment: "打开照片文件夹"))
                                }
                                .font(.caption)
                                .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            Text(String(format: NSLocalizedString("snapshots_count", comment: "已保存 %d 张照片"), viewModel.snapshots.count))
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        
                        Divider()
                        
                        // 坐姿检测设置
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "figure.stand")
                                    .foregroundColor(.accentColor)
                                Text(NSLocalizedString("posture_detection_settings", comment: "坐姿检测"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            Toggle(NSLocalizedString("enable_posture_detection", comment: "启用坐姿检测"), isOn: $viewModel.isPostureDetectionEnabled)
                                .toggleStyle(.switch)
                            
                            Text(NSLocalizedString("posture_detection_description", comment: "实时检测坐姿，提醒保持正确姿势"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 当前坐姿状态
                            HStack {
                                Text(NSLocalizedString("current_posture", comment: "当前坐姿"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(viewModel.currentPosture.localizedName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(viewModel.currentPosture == .good ? .green : .orange)
                            }
                            
                            Divider()
                            
                            // 坐姿提醒详细设置
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "bell.badge")
                                        .foregroundColor(.accentColor)
                                    Text(NSLocalizedString("posture_alert_settings", comment: "坐姿提醒设置"))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Toggle(NSLocalizedString("enable_posture_alert", comment: "启用坐姿提醒"), isOn: $viewModel.isPostureAlertEnabled)
                                    .toggleStyle(.switch)
                                
                                Text(NSLocalizedString("posture_alert_description", comment: "不良坐姿持续时渐进式提醒"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if viewModel.isPostureAlertEnabled {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Toggle(NSLocalizedString("posture_sound_alert", comment: "声音"), isOn: $viewModel.isPostureSoundEnabled)
                                            .toggleStyle(.checkbox)
                                        
                                        Toggle(NSLocalizedString("posture_haptic_alert", comment: "震动"), isOn: $viewModel.isPostureHapticEnabled)
                                            .toggleStyle(.checkbox)
                                        
                                        Toggle(NSLocalizedString("posture_banner_alert", comment: "通知横幅"), isOn: $viewModel.isPostureBannerEnabled)
                                            .toggleStyle(.checkbox)
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // 阈值设置
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(NSLocalizedString("drowsy_threshold", comment: ""))
                                Spacer()
                                Text("\(Int(viewModel.drowsyThreshold)) \(NSLocalizedString("seconds", comment: ""))")
                                    .foregroundColor(.accentColor).bold()
                            }
                            
                            Slider(value: $viewModel.drowsyThreshold, in: 1...5, step: 1)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                    
                    // 数据导出
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(NSLocalizedString("export_data", comment: ""))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(20)
            }
            
            // 底部退出按钮
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text(NSLocalizedString("quit", comment: "Quit App"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding(16)
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
