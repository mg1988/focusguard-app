import SwiftUI

/// 灵敏度选择器组件，适配 macOS 原生 Segmented Picker 样式
struct SensitivityPicker: View {
    @Binding var selection: Sensitivity
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("sensitivity", comment: "Sensitivity Selection Label"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("", selection: $selection) {
                ForEach(Sensitivity.allCases, id: \.self) { sensitivity in
                    Text(sensitivity.localizedName).tag(sensitivity)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!isEnabled) // 专注中不可切换灵敏度
        }
    }
}

struct SensitivityPicker_Previews: PreviewProvider {
    static var previews: some View {
        SensitivityPicker(selection: .constant(.medium), isEnabled: true)
            .padding()
            .frame(width: 300)
    }
}
