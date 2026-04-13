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
                        Toggle(NSLocalizedString("sound_alerts", comment: ""), isOn: $viewModel.isSoundEnabled)
                            .toggleStyle(.switch)
                        
                        Toggle(NSLocalizedString("haptic_alerts", comment: ""), isOn: $viewModel.isHapticEnabled)
                            .toggleStyle(.switch)
                        
                        Divider()
                        
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
            
            // 底部退出按钮，固定位置
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
}
