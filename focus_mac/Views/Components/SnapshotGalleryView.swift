import SwiftUI

/// 抓拍照片画廊视图，展示所有走神/瞌睡瞬间的抓拍照片
struct SnapshotGalleryView: View {
    @ObservedObject var viewModel: FocusViewModel
    @State private var selectedSnapshot: DistractionSnapshot?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack {
                Text("snapshots_gallery".localized)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                // 启用/禁用抓拍开关
                Toggle(isOn: $viewModel.isSnapshotEnabled) {
                    Text("enable_snapshots".localized)
                        .font(.system(size: 12))
                }
                .toggleStyle(.switch)
                
                // 清空按钮
                if !viewModel.snapshots.isEmpty {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("clear_all_snapshots".localized)
                }
            }
            
            // 照片网格
            if viewModel.snapshots.isEmpty {
                EmptyStateView()
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(viewModel.snapshots) { snapshot in
                            SnapshotThumbnailView(snapshot: snapshot)
                                .onTapGesture {
                                    selectedSnapshot = snapshot
                                }
                        }
                        .onDelete(perform: deleteSnapshots)
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(16)
        .sheet(item: $selectedSnapshot) { snapshot in
            SnapshotDetailView(snapshot: snapshot, viewModel: viewModel)
        }
        .alert(
            "clear_all_snapshots".localized,
            isPresented: $showDeleteConfirmation
        ) {
            Button("cancel".localized, role: .cancel) {}
            Button("delete".localized, role: .destructive) {
                viewModel.clearAllSnapshots()
            }
        } message: {
            Text("clear_all_snapshots_message".localized)
        }
    }
    
    private func deleteSnapshots(at indexSet: IndexSet) {
        viewModel.deleteSnapshot(at: indexSet)
    }
}

/// 照片缩略图视图
struct SnapshotThumbnailView: View {
    let snapshot: DistractionSnapshot
    @State private var image: NSImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 图片容器
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.05))
                    .frame(height: 120)
                
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                // 类型图标
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: snapshot.type.iconName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(snapshot.type == .distraction ? Color.orange : Color.blue)
                            )
                            .padding(6)
                    }
                    Spacer()
                }
            }
            
            // 时间信息
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDate(snapshot.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text(formatDuration(snapshot.duration))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(snapshot.type == .distraction ? .orange : .blue)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = NSImage(contentsOfFile: snapshot.imagePath) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let seconds = Int(duration)
        return "triggered_after".localized(with: seconds)
    }
}

/// 照片详情查看视图
struct SnapshotDetailView: View {
    let snapshot: DistractionSnapshot
    @ObservedObject var viewModel: FocusViewModel
    @Environment(\.dismiss) var dismiss
    @State private var image: NSImage?
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Text(snapshot.type.localizedName)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.primary.opacity(0.05))
            
            // 图片展示
            ZStack {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 底部信息
            VStack(spacing: 8) {
                Text(formatDate(snapshot.timestamp))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("triggered_after_format".localized(with: Int(snapshot.duration)))
                    .font(.system(size: 12))
                    .foregroundColor(snapshot.type == .distraction ? .orange : .blue)
            }
            .padding(16)
            .background(Color.primary.opacity(0.05))
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadImage()
        }
        .alert(
            "delete_snapshot".localized,
            isPresented: $showDeleteAlert
        ) {
            Button("cancel".localized, role: .cancel) {}
            Button("delete".localized, role: .destructive) {
                deleteSnapshot()
                dismiss()
            }
        } message: {
            Text("delete_snapshot_message".localized)
        }
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedImage = NSImage(contentsOfFile: snapshot.imagePath) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
    
    private func deleteSnapshot() {
        if let index = viewModel.snapshots.firstIndex(where: { $0.id == snapshot.id }) {
            viewModel.deleteSnapshot(at: IndexSet(integer: index))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

/// 空状态视图
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("no_snapshots".localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("no_snapshots_description".localized)
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

struct SnapshotGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotGalleryView(viewModel: FocusViewModel())
    }
}
