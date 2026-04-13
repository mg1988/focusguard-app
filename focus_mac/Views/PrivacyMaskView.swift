import SwiftUI

/// 隐私保护声明视图 (Privacy Mask)
struct PrivacyMaskView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkerboard")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text(NSLocalizedString("privacy_title", comment: ""))
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 12) {
                PrivacyItem(icon: "cpu", text: NSLocalizedString("privacy_local", comment: ""))
                PrivacyItem(icon: "eye.slash", text: NSLocalizedString("privacy_no_store", comment: ""))
                PrivacyItem(icon: "network.slash", text: NSLocalizedString("privacy_no_upload", comment: ""))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
            
            Button(NSLocalizedString("privacy_got_it", comment: "")) {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(30)
        .frame(width: 320)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
    }
}

struct PrivacyItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }
}
