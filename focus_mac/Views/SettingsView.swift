import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
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
            
            Spacer()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text(NSLocalizedString("quit", comment: "Quit App"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }
}
